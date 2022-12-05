variable "project_name" {}
variable "instance_type" {}
variable "key_name" {}
variable "ec_security_group_id" {}
variable "ec_be_security_group_id" {}
variable "ec_bastion_security_group_id" {}


variable "max_number_of_instances" {}
variable "min_number_of_instances" {}
variable "desired_capacity" {}
variable "bastion_max_number_of_instances" {}
variable "bastion_min_number_of_instances" {}
variable "bastion_desired_capacity" {}
variable "asg_health_check_type" {}
variable "public_subnet_az1_id" {}
variable "public_subnet_az2_id" {}
variable "private_app_subnet_az1_id" {}
variable "private_app_subnet_az2_id" {}
variable "alb_target_group_arn" {}