# From vpc module
variable "region" {}
#variable "phase" {}
#variable "application_name" {}
variable "project_name" {}
variable "vpc_cidr" {}
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}
variable "private_app_subnet_az1_cidr" {}
variable "private_app_subnet_az2_cidr" {}
variable "private_data_subnet_az1_cidr" {}
variable "private_data_subnet_az2_cidr" {}

# From acm module
variable "domain_name" {}
variable "alternative_name" {}

# From database module
variable "db_name" {
  type = string
}
variable "db_user" {
  type      = string
  sensitive = true
}
variable "db_password" {
  type      = string
  sensitive = true
}

# From compute module
variable "key_name" {}