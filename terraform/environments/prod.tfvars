aws_region             = "us-east-1"
project_name           = "WellNest"
aws_account_id         = "006805625766"
key_name               = "bha26"
github_repo            = "https://github.com/Bharath-1602/WellNest-AWS.git"
domain_name            = "wellnest-project.online"
ops_email              = "bharath70135@gmail.com"

# Instance configurations
bastion_instance_type  = "t3.micro"
frontend_instance_type = "t3.micro"
backend_instance_type  = "t3.small"

# Custom AMIs
frontend_ami_id        = "ami-02f07081de00d2b9a"
backend_ami_id         = "ami-0083a76ac555094c5"

# Auto Scaling configuration for Production (scales up to 2 nodes)
frontend_min_size         = 1
frontend_max_size         = 2
frontend_desired_capacity = 1
backend_min_size          = 1
backend_max_size          = 2
backend_desired_capacity  = 1

# CloudFront enabled for production
enable_cloudfront         = true
