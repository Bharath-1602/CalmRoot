# Retrieve the latest Ubuntu 22.04 LTS AMI ID for Bastion
data "aws_ssm_parameter" "ubuntu" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# Bastion Host (Single instance in Public Subnet)
resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.ubuntu.value
  instance_type               = var.bastion_instance_type
  subnet_id                   = var.bastion_subnet_id
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "wellnest-${terraform.workspace}-bastion"
  }
}
