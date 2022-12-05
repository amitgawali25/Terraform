# Create security group for the ALB
resource "aws_security_group" "alb_security_group" {
  name        = "alb security group"
  description = "enable http/https access on port 80/443"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

# SSH access from anywhere
  ingress {
    
    description = "SSH access"

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# Allow Ping
ingress {
    description = "ICMP/Ping access"

    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# All traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "ALB Security Group"
  }
}

# Create security group for the FrontEnd ECs
resource "aws_security_group" "ec_security_group" {
  name        = "EC security group"
  description = "enable http/https access on port 80/443 via alb sg"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_security_group.id]
  }

  ingress {
    description      = "HTTPS access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_security_group.id]
  }
  
# SSH access from anywhere
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups  = [aws_security_group.ec_bastion_security_group.id]

  }

  # Allow Ping
  ingress {
    description = "ICMP/Ping access"

    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # All traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "EC Security Group"
  }
}

# Create security group for the Bastion EC2s
resource "aws_security_group" "ec_bastion_security_group" {
  name        = "Bastion EC2 security group"
  description = "Allow SSH and ICMP/Ping access"
  vpc_id      = var.vpc_id

# SSH access from anywhere
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ! Todo add specific IP with var
  }

  # Allow Ping
  ingress {
    description = "ICMP/Ping access"

    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"] # ! Todo add specific IP with var
  }
  
  # All traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Bastion EC2 Security Group"
  }
}


# Create security group for the Backend EC2s
resource "aws_security_group" "ec_be_security_group" {
  name        = "EC Backend security group"
  description = "enable http/https access on port 80/443 via FE EC2 and SSH via Bastion"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.ec_security_group.id]
  }

  ingress {
    description      = "HTTPS access"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_security_group.ec_security_group.id]
  }
  
# SSH access a bastion server
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]              
    security_groups  = [aws_security_group.ec_bastion_security_group.id]
  }

/*
  # Allow Ping
  ingress {
    description = "ICMP/Ping access"

    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  */
  
  # All traffic
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "Backend EC2 Security Group"
  }
}


# Create Database Security Group 
resource "aws_security_group" "db_security_group" {
  name        = "DB Security Group"
  description = "Allow inbound traffic from app backend layer"
  vpc_id      = var.vpc_id
ingress {
    description     = "Allow traffic from app backend layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups  = [aws_security_group.ec_be_security_group.id] 
  }

  # SSH access a bastion server
ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups  = [aws_security_group.ec_bastion_security_group.id]
  }

egress {
    from_port   = 32768                  # MySql port
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

tags = {
    Name = "DB Security Group"
  }
}