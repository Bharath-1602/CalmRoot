terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "wellnest-tf-state-006805625766"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "wellnest-tf-state-lock"
    encrypt        = true
  }
}
