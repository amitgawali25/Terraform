# Configure AWS provider
provider "aws" {
    region = var.region
    profile = "iac-admin-user"
}

# Create VPC
module "vpc" {

    source                          = "../modules/vpc"
    region                          = var.region
    project_name                    = var.project_name
    vpc_cidr                        = var.vpc_cidr
    public_subnet_az1_cidr          = var.public_subnet_az1_cidr
    public_subnet_az2_cidr          = var.public_subnet_az2_cidr
    private_app_subnet_az1_cidr     = var.private_app_subnet_az1_cidr
    private_app_subnet_az2_cidr     = var.private_app_subnet_az2_cidr
    private_data_subnet_az1_cidr    = var.private_data_subnet_az1_cidr
    private_data_subnet_az2_cidr    = var.private_data_subnet_az2_cidr
}

# Create NAT Gateways
module "nat_gateway" {
    source                          = "../modules/nat-gateway"
 
    public_subnet_az1_id            = module.vpc.public_subnet_az1_id
    internet_gateway                = module.vpc.internet_gateway
    public_subnet_az2_id            = module.vpc.public_subnet_az2_id
    vpc_id                          = module.vpc.vpc_id
    private_app_subnet_az1_id       = module.vpc.private_app_subnet_az1_id
    private_data_subnet_az1_id      = module.vpc.private_data_subnet_az1_id  
    private_app_subnet_az2_id       = module.vpc.private_app_subnet_az2_id
    private_data_subnet_az2_id      = module.vpc.private_data_subnet_az2_id  
}

# Create Security Groups
module "security-group" {
    source                          = "../modules/security-groups"
    vpc_id                          = module.vpc.vpc_id
}

/*  Create Certificate for domain
# ACM
module "acm" {
  
  source            = "../modules/acm"
  domain_name       = var.domain_name
  alternative_name  = var.alternative_name

}
*/

# Create ALB
module "application_load_balancer" {
    source                          = "../modules/alb"

    project_name                    = module.vpc.project_name
    alb_security_group_id           = module.security-group.alb_security_group_id
    public_subnet_az1_id            = module.vpc.public_subnet_az1_id
    public_subnet_az2_id            = module.vpc.public_subnet_az2_id
    vpc_id                          = module.vpc.vpc_id
#    certificate_arn                = module.acm.certificate_arn
    
}


# Create DB
module "db" {
    source                          = "../modules/database"

    private_data_subnet_az1_id      = module.vpc.private_data_subnet_az1_id
    private_data_subnet_az2_id      = module.vpc.private_data_subnet_az2_id
    db_security_group_id            = module.security-group.db_security_group_id

    db_allocated_storage            = 10
    db_engine                       = "mysql"
    db_engine_version               = "5.7.40" 
    db_instance_class               = "db.t2.micro"
    db_name                         = var.db_name
    db_user                         = var.db_user
    db_password                     = var.db_password
    
}


/* Use AutoscaledCompute instead
# Create EC2
module "App" {
    source                          = "../modules/compute"

    instance_type                   = "t2.micro"
    key_name                        = var.key_name
    ec_security_group_id            = module.security-group.ec_security_group_id
    public_subnet_az1_id            = module.vpc.public_subnet_az1_id
    public_subnet_az2_id            = module.vpc.public_subnet_az2_id

}
*/

# Create AutoScaled Compute
# ! todo ideally need a separate module for FE, BE and Bastion EC2
module "autoscaledCompute" {
    source                          = "../modules/autoscaledCompute"

    project_name                    = module.vpc.project_name
    instance_type                   = "t2.micro"                # Todo - should be configirable based on SLO
    key_name                        = var.key_name            
    ec_security_group_id            = module.security-group.ec_security_group_id
    ec_be_security_group_id         = module.security-group.ec_be_security_group_id
    ec_bastion_security_group_id    = module.security-group.ec_bastion_security_group_id

    max_number_of_instances         = 4
    min_number_of_instances         = 2
    desired_capacity                = 2
    asg_health_check_type           = "ELB"

    # For Bastion
    bastion_max_number_of_instances = 1
    bastion_min_number_of_instances = 1
    bastion_desired_capacity        = 1

    public_subnet_az1_id            = module.vpc.public_subnet_az1_id
    public_subnet_az2_id            = module.vpc.public_subnet_az2_id
    private_app_subnet_az1_id       = module.vpc.private_app_subnet_az1_id
    private_app_subnet_az2_id       = module.vpc.private_app_subnet_az2_id
    alb_target_group_arn            = module.application_load_balancer.alb_target_group_arn
}   