output "frontend_ecr_repository_url" {
  description = "URL of the SecureCart frontend ECR repository"
  value       = module.registry_identity.frontend_ecr_repository_url
}

output "backend_ecr_repository_url" {
  description = "URL of the SecureCart backend ECR repository"
  value       = module.registry_identity.backend_ecr_repository_url
}

output "github_ecr_publisher_role_arn" {
  description = "ARN of the IAM role used by GitHub Actions to publish images to ECR"
  value       = module.registry_identity.github_ecr_publisher_role_arn
}
