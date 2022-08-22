terraform {
  backend "remote" {
    organization = "terraform-enterprise-modules-test"

    workspaces {
      name = "aws-private-tcp-active-active"
    }
  }

  required_version = ">= 0.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  assume_role {
    role_arn = var.aws_role_arn
  }
}
