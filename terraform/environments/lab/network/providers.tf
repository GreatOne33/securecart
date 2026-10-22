provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "SecureCart"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
