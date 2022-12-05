
/*
data "aws_ami" "amazon_linux" {
  #executable_users = ["self"]
  most_recent      = true
  name_regex       = "^myami-\\d{3}"
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["myami-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
*/

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*"
    ]

    # AmazonLinux 2 if you want
    # "amzn2-ami-hvm-*"
  }

  filter {
    name = "root-device-type"

    values = [
      "ebs",
    ]
  }

  filter {
    name = "architecture"

    values = [
      "x86_64",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }

  owners = [
    "amazon",
    "self",
  ]
}


# Creating 1st EC2 instance in Public Subnet
resource "aws_instance" "app_instance-1" {
  #ami                         = data.aws_ami.amazon_linux.image_id
  ami                         = "ami-0b0dcb5067f052a63"
  instance_type               = var.instance_type
  count                       = 1
  key_name                    = var.key_name
  vpc_security_group_ids      = ["${var.ec_security_group_id}"]
  subnet_id                   = "${var.public_subnet_az1_id}"
  associate_public_ip_address = true
  user_data                   = "${file("../modules/compute/installApp.sh")}"

  tags = {
    Name = "Public EC2 instance 1",
  }
}

# Creating 2nd EC2 instance in Public Subnet
resource "aws_instance" "app_instance-2" {
  #ami                         = data.aws_ami.amazon_linux.image_id
  ami                         = "ami-0b0dcb5067f052a63"
  instance_type               = var.instance_type
  count                       = 1
  key_name                    = var.key_name
  vpc_security_group_ids      = ["${var.ec_security_group_id}"]
  subnet_id                   = "${var.public_subnet_az2_id}"
  associate_public_ip_address = true
  user_data                   = "${file("../modules/compute/installApp.sh")}"

  tags = {
    Name = "Public EC2 instance 2",
  }
}

