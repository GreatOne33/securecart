output "vpc_id" {
  description = "ID of the SecureCart VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets used for internet-facing AWS resources"
  value = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets used for SecureCart workloads"
  value = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

output "frontend_ecr_repository_url" {
  description = "URL of the SecureCart frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "URL of the SecureCart backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}
