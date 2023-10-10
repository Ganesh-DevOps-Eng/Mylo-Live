
variable "environment" {}


#vpc module

variable "project_name" {}
variable "vpc_cidr" {}
variable "az_count" {}

#key module

variable "ami_id" {}
variable "instance_type" {}

#root53 domin

variable "root_domain_name" {}
