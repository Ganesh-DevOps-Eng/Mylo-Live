module "VPC-Module" {
  source       = "../VPC-Module"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  az_count     = var.az_count
}

resource "aws_instance" "bastion" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = module.VPC-Module.subnet-public[0]
  vpc_security_group_ids = [module.VPC-Module.bastion_sg]

  key_name = aws_key_pair.bastion_pair.key_name
}