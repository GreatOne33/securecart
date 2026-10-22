output "frontend_ecr_repository_url" {
  description = "URL of the SecureCart frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "URL of the SecureCart backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "github_ecr_publisher_role_arn" {
  description = "ARN of the IAM role used by GitHub Actions to publish images to ECR"
  value       = aws_iam_role.github_ecr_publisher.arn
}
