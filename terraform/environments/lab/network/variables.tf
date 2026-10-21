variable "aws_region" {
  description = "AWS region for SecureCart networking"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "securecart"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "lab"
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block for the lab VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the lab public subnets"
  type        = list(string)

  default = [
    "10.20.0.0/24",
    "10.20.1.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the lab private subnets"
  type        = list(string)

  default = [
    "10.20.10.0/24",
    "10.20.11.0/24"
  ]
}

variable "enable_nat_gateway" {
  description = "Whether to deploy a NAT gateway for private subnet internet access"
  type        = bool
  default     = false
}
