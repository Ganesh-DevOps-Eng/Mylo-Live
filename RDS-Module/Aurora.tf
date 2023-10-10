
# ### RDS AURORA_CLUSTER ####
# resource "random_password" "password" {
#   length  = 16
#   special = true
# }

# # Creating a AWS secret for database master account (Masteraccoundb)
# resource "aws_secretsmanager_secret" "secretmaster" {
#   name = "MasterDBPassword-${var.environment}-2"
# }


# # Creating a AWS secret versions for database master account (Masteraccoundb)
# resource "aws_secretsmanager_secret_version" "sversion" {
#   secret_id     = aws_secretsmanager_secret.secretmaster.id
#   secret_string = random_password.password.result
# }


resource "aws_security_group" "aurora_sg" {
  name_prefix = "Dastan"
  vpc_id      = module.VPC-Module.vpc_id
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.VPC-Module.public_cidr
  }
  egress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Aurora"
  }
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "dastan"
  subnet_ids = module.VPC-Module.subnet-public[*]
}

resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "dastan"
  engine             = "aurora-postgresql"
  engine_version     = "14.6"
  database_name      = "Dastan_db"
  master_username    = "postgres"
  master_password    = "01Matellio1234"
  #master_password             = filebase64("pass.txt")
  backup_retention_period      = 7
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sat:08:00-sat:09:00"
  skip_final_snapshot          = true
  db_subnet_group_name         = aws_db_subnet_group.aurora_subnet_group.name

  vpc_security_group_ids = [aws_security_group.aurora_sg.id]
}

resource "aws_rds_cluster_instance" "aurora_instance" {
  cluster_identifier   = aws_rds_cluster.aurora_cluster.id
  instance_class       = "db.t3.medium"
  engine_version       = "14.6"
  identifier_prefix    = "dastan-instance"
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
  engine               = "aurora-postgresql"
  #   performance_insights_enabled    = true
  #   performance_insights_retention_period = "7"
  #   performance_insights_kms_key_id = var.performance_insights_kms_key_id
  #   monitoring_interval = 60
  #   monitoring_role_arn = var.monitoring_role_arn
}