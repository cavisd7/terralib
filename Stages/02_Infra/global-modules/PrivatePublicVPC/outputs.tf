output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
    value = module.private_public_subnets.private_subnet_ids
}