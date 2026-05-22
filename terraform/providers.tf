terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "nexacart-tf-state"
    key            = "production/nexacart.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "nexacart-tf-locks"
    encrypt        = true
  }
}

provider "aws" { region = var.aws_region }