output "vpc_id" {
  value = aws_vpc.eks_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.eks_public_subnet[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.eks_private_subnet[*].id
}
