resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "calmroot-${terraform.workspace}-hosted-zone"
  }
}
