output "vpc_id" {
  description = "ID of the SecureCart lab VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the lab public subnets"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the lab private subnets"
  value       = module.network.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the lab Internet Gateway"
  value       = module.network.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT gateway, or null when disabled"
  value       = module.network.nat_gateway_id
}

output "s3_endpoint_id" {
  description = "ID of the lab S3 Gateway VPC endpoint"
  value       = module.network.s3_endpoint_id
}
