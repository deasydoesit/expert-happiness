output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.this.id, null)
}

output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = try(aws_subnet.public[*].id, null)
}

output "private_subnets_ids" {
  description = "List of IDs of private subnets"
  value       = try(aws_subnet.private[*].id, null)
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.this.id, null)
}
