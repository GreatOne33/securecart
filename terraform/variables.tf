variable "aws_region" {
  description = "AWS region used to deploy SecureCart infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "securecart"
}

variable "environment" {
  description = "Deployment environment for SecureCart"
  type        = string
  default     = "lab"
}
