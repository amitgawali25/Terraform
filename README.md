# AWS - 3 Tier Application using Terraform
Sample Three Tier Application on AWS built using Terraform and Python.


## Architecture

![AWS - 3 Tier Application Architecture](https://github.com/amitgawali25/Terraform/blob/main/ThreeTierApplication/assets/images/AWS%20-%203%20Tier%20Application%20Architecture.png)


## Pre-requisites
- Basics of AWS, Python and Shell scripting
- AWS account and programatic access
- Local installation for Terraform and AWS CLI 
- Python 3
- Domain regsitered if trying ACM


## Key Setup 
- VPC with 2 avaliability zones and default Main Route Table
- Internet Gateway
- Security Groups for ALB, Frontend EC2s, Bastion, Backend EC2s and Database
- 1 public subnet in each AZ with
  - ALB, Target Groups
  - NAT Gateway, 2 Elastic IPs
  - Autoscaling group for Bastion allowing SSH to FE, BE and Database
  - Autoscaling group for Frontend EC2 hosting Apache web server
  - Public Route Table
- 1 private subnet in each AZ for application backend
  - Running Nodejs
  - Private Route table with entry for outgoing internet traffic via NAT Gateway
- 1 private subnet in each AZ for database 
  - Mutli-AZ RDS DB runing MySQL
  - Primary DB in AZ1 with replication in place for Secondary DB instance in AZ2
  - Private Route table with entry for outgoing internet traffic via NAT Gateway

## Repository Structure

The content source files are located in the following directories:

```text
.
├── Terraform
│   └── README.md  
│   └── modules                      //< Has all reusable terraform modules (each having main.tf,variable.tf and output.tf file)
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
