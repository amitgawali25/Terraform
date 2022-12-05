#!/bin/bash

yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo "Hello World! from EC instance  $(hostname -f)" > /var/www/html/index.html
pip3 install requests
pip3 install icecream