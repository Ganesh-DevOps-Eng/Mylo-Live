# Key Pair Server
resource "tls_private_key" "my_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "local_file" "private_key" {
  content         = tls_private_key.my_private_key.private_key_pem
  filename        = "${var.project_name}_private_key.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "${var.project_name}_key_pair"
  public_key = tls_private_key.my_private_key.public_key_openssh
}

# Key Pair Bastion
resource "tls_private_key" "my_bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "bastion_key" {
  content         = tls_private_key.my_bastion_key.private_key_pem
  filename        = "${var.project_name}_bastion_key.pem"
  file_permission = "0400"
}

resource "aws_key_pair" "bastion_pair" {
  key_name   = "${var.project_name}_bastion_key_pair"
  public_key = tls_private_key.my_bastion_key.public_key_openssh
}
