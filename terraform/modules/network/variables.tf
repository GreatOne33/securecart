variable "project_name" {
  description = "Project name used for AWS resource naming"
  type        = string
}

variable "environment" {
  description = "Deployment environment, such as lab, staging, or production"
  type        = string
}

variable "aws_region" {
  description = "AWS region used for regional service endpoints"
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Whether to provision a NAT gateway for private subnet internet access"
  type        = bool
  default     = false
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets"
  type        = list(string)

  default = [
    "10.20.0.0/24",
    "10.20.1.0/24"
  ]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDRs must be provided."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the two private subnets"
  type        = list(string)

  default = [
    "10.20.10.0/24",
    "10.20.11.0/24"
  ]

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Exactly two private subnet CIDRs must be provided."
  }
}
