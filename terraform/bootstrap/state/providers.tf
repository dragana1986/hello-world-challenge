# Tells Terraform which providers/versions to use, and configures AWS.
terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"          # hint: "~> 5.0" allows 5.x but not 6.0 (safe pinning)
    }
  }
}

provider "aws" {
  region = var.region            # comes from variables.tf below
}