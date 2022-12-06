# AWS - 3 Tier Application using Terraform
Sample Three Tier Application on AWS built using Terraform and Python.


## Architecture

![AWS - 3 Tier Application Architecture](https://github.com/amitgawali25/Terraform/blob/main/ThreeTierApplication/assets/images/AWS%20-%203%20Tier%20Application%20Architecture.png)



## Repository Structure

The content source files are located in the following directories:

```text
.
├── Terraform
│   └── README.md  
│   └── modules                      //< Has all reusable terraform modules (each module has main.tf,variable.tf and output.tf file)
│   │     ├── acm                      //< AWS Cetrificate Manager
│   │     ├── alb                      //< Application Load Balancer
│   │     ├── autoscaledCompute        //< Autoscaling groups for Bastion, Frontend and Backend EC2
│   │     ├── compute                  //< Non-autoscaled EC2
│   │     ├── database                 //< RDS DB
│   │     ├── nat-gateway              //< NAT Gateway in Public Availibilty Zones
│   │     ├── security-groups          //< Security groups for ALB, Bastion, Frontend, Backend and Database
│   │     ├── vpc                      //< VPC, Internet Gateway, Public and Private Subnets, Route tables
│   └── ThreeTierApplication         //< Three tier application
│       └── assets                     //< Folder to store assets for project.
│       │   └── images                 //< Images
│       ├── main.tf                    //< Main configurations for all modules needed
│       ├── variable.tf                //< Variables definitions
│       ├── output.tf                  //< Output definitions
│       └── terraform.tfvars           //< Global variables assignments
