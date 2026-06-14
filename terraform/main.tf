# Get regional metadata dynamically
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# 1. VPC Module (Networking Foundation using official terraform-aws-modules)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "calmroot-${terraform.workspace}-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = [for cidr in values(var.web_public_subnets) : cidr]
  private_subnets = [for cidr in values(var.app_private_subnets) : cidr]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# 2. Security Groups Module
module "security_groups" {
  source       = "./modules/security_groups"
  project_name = var.project_name
  vpc_id       = module.vpc.vpc_id
}

# 3. IAM (Exposing Pre-existing backend role details)
module "iam" {
  source                   = "./modules/iam"
  project_name             = var.project_name
  aws_account_id           = data.aws_caller_identity.current.account_id
  existing_dynamodb_tables = var.existing_dynamodb_tables
  existing_s3_buckets      = var.existing_s3_buckets
  existing_secrets         = var.existing_secrets
}

# 4. KMS Module (Customer Managed Key for logs & SNS encryption)
module "kms" {
  source         = "./modules/kms"
  project_name   = var.project_name
  aws_account_id = data.aws_caller_identity.current.account_id
}

# 5. VPC Endpoints Module (Gateway S3/DDB & Interface Endpoints)
module "vpc_endpoints" {
  source                      = "./modules/vpc_endpoints"
  project_name                = var.project_name
  vpc_id                      = module.vpc.vpc_id
  vpc_cidr                    = var.vpc_cidr
  private_subnet_ids          = module.vpc.private_subnets
  app_private_route_table_ids = module.vpc.private_route_table_ids
}

# 6. Load Balancers Module
module "alb" {
  source             = "./modules/alb"
  project_name       = var.project_name
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnets
  private_subnet_ids = module.vpc.private_subnets
  public_alb_sg_id   = module.security_groups.public_alb_sg_id
  internal_alb_sg_id = module.security_groups.internal_alb_sg_id
  certificate_arn    = module.acm.certificate_arn
  logs_bucket_name   = aws_s3_bucket.logs.id
}

# 7. Route53 Module (Public Hosted Zone creation only)
module "route53" {
  source       = "./modules/route53"
  domain_name  = var.domain_name
}

# 8. ACM Module (wildcard SSL request and validation)
module "acm" {
  source      = "./modules/acm"
  domain_name = var.domain_name
  zone_id     = module.route53.zone_id
}

# 9. WAF Module (WAF ACL rules for CloudFront)
module "waf" {
  source       = "./modules/waf"
  project_name = var.project_name
}

# 10. CloudFront Module (CDN caching and behaviors)
module "cloudfront" {
  count           = var.enable_cloudfront ? 1 : 0
  source          = "./modules/cloudfront"
  project_name    = var.project_name
  domain_name     = var.domain_name
  public_alb_dns  = "origin.${var.domain_name}"
  certificate_arn = module.acm.certificate_arn
  waf_arn         = module.waf.waf_arn
}

# 11. Launch Template Module (Launch templates for ASGs)
module "launch_template" {
  source                        = "./modules/launch_template"
  project_name                  = var.project_name
  key_name                      = var.key_name
  frontend_instance_type        = var.frontend_instance_type
  backend_instance_type         = var.backend_instance_type
  frontend_ami_id               = var.frontend_ami_id
  backend_ami_id                = var.backend_ami_id
  web_sg_id                     = module.security_groups.web_sg_id
  app_sg_id                     = module.security_groups.app_sg_id
  backend_instance_profile_name = module.iam.instance_profile_name
  internal_alb_dns_name         = module.alb.internal_alb_dns_name
}

# 12. Auto Scaling Group Module (ASGs and scaling policies)
module "asg" {
  source                      = "./modules/asg"
  project_name                = var.project_name
  frontend_launch_template_id      = module.launch_template.frontend_launch_template_id
  frontend_launch_template_version = module.launch_template.frontend_launch_template_latest_version
  backend_launch_template_id       = module.launch_template.backend_launch_template_id
  backend_launch_template_version  = module.launch_template.backend_launch_template_latest_version
  public_subnet_ids           = module.vpc.public_subnets
  private_subnet_ids          = module.vpc.private_subnets
  frontend_tg_arn             = module.alb.frontend_tg_arn
  auth_tg_arn                 = module.alb.auth_tg_arn
  assessment_tg_arn           = module.alb.assessment_tg_arn
  therapist_tg_arn            = module.alb.therapist_tg_arn

  # Scaling Sizes
  frontend_min_size         = var.frontend_min_size
  frontend_max_size         = var.frontend_max_size
  frontend_desired_capacity = var.frontend_desired_capacity
  backend_min_size          = var.backend_min_size
  backend_max_size          = var.backend_max_size
  backend_desired_capacity  = var.backend_desired_capacity

  sns_topic_arn = module.sns.raw_sns_topic_arn
}

# 13. EC2 Module (Bastion host instance)
module "ec2" {
  source                = "./modules/ec2"
  project_name          = var.project_name
  key_name              = var.key_name
  bastion_instance_type = var.bastion_instance_type
  bastion_subnet_id     = module.vpc.public_subnets[0]
  bastion_sg_id         = module.security_groups.bastion_sg_id
}

# 14. Lambda Module (Daily export & Alarm notifier functions)
module "lambda" {
  source         = "./modules/lambda"
  project_name   = var.project_name
  aws_account_id = data.aws_caller_identity.current.account_id
  kms_key_arn    = module.kms.key_arn
  sns_topic_arn  = "arn:aws:sns:us-east-1:${data.aws_caller_identity.current.account_id}:calmroot-${terraform.workspace}-ops-alarms"
  ops_email      = var.ops_email
}


# 15. SNS Module (Alarms & ops topics)
module "sns" {
  source                    = "./modules/sns"
  project_name              = var.project_name
  kms_key_arn               = module.kms.key_arn
  ops_email                 = var.ops_email
  alarm_notifier_lambda_arn = module.lambda.alarm_notifier_lambda_arn
}

# 16. CloudWatch Module (Log groups & metric alarms)
module "cloudwatch" {
  source                          = "./modules/cloudwatch"
  project_name                    = var.project_name
  kms_key_arn                     = module.kms.key_arn
  raw_sns_topic_arn               = module.sns.raw_sns_topic_arn
  public_alb_arn_suffix           = module.alb.public_alb_arn_suffix
  internal_alb_arn_suffix         = module.alb.internal_alb_arn_suffix
  internal_alb_auth_tg_arn_suffix = module.alb.auth_tg_arn_suffix
  frontend_asg_name               = module.asg.frontend_asg_name
  backend_asg_name                = module.asg.backend_asg_name
}

# ==========================================
# Route53 Alias Records
# ==========================================

# A Record for CloudFront Origin Domain pointing to Public ALB
resource "aws_route53_record" "origin" {
  zone_id = module.route53.zone_id
  name    = "origin.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.alb.public_alb_dns_name
    zone_id                = module.alb.public_alb_zone_id
    evaluate_target_health = true
  }
}

# A Record for Apex domain
resource "aws_route53_record" "apex" {
  zone_id = module.route53.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.enable_cloudfront ? module.cloudfront[0].cloudfront_domain_name : module.alb.public_alb_dns_name
    zone_id                = var.enable_cloudfront ? module.cloudfront[0].cloudfront_hosted_zone_id : module.alb.public_alb_zone_id
    evaluate_target_health = true
  }
}

# A Record for www subdomain
resource "aws_route53_record" "www" {
  zone_id = module.route53.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.enable_cloudfront ? module.cloudfront[0].cloudfront_domain_name : module.alb.public_alb_dns_name
    zone_id                = var.enable_cloudfront ? module.cloudfront[0].cloudfront_hosted_zone_id : module.alb.public_alb_zone_id
    evaluate_target_health = true
  }
}
