#Security Group output id

output "bastion_sg" {
  value = aws_security_group.bastion_sg.id
}

output "server_sg" {
  value = aws_security_group.server_sg.id
}


output "rds_sg" {
  value = aws_security_group.rds_sg.id
}
output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

#Network output id's

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet-public" {
  value = aws_subnet.public[*].id
}


output "subnet-private" {
  value = aws_subnet.private[*].id
}

output "public_cidr" {
  value = aws_subnet.public[*].cidr_block
}