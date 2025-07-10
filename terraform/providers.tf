# Pinned provider requirements
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Config provider for environment
provider "aws" {
  region = "us-east-1"
}


