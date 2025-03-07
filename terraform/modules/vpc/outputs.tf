output "vpc_id" {
  description = "The ID of the main VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway."
  value       = aws_nat_gateway.nat.id
}
