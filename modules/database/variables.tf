variable "private_data_subnet_az1_id" {}
variable "private_data_subnet_az2_id" {}
variable "db_security_group_id" {}

variable "db_allocated_storage" {}
variable "db_engine" {}
variable "db_engine_version" {}
variable "db_instance_class" {}
variable "db_name" {}
variable "db_user" {}
variable "db_password" {}  # ! make sensitive
