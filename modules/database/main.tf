# Creating RDS Instance
resource "aws_db_subnet_group" "db_sg" {
  name       = "db_subnet_group"                     # ! todo add var for instance name
  subnet_ids = [var.private_data_subnet_az1_id, var.private_data_subnet_az2_id]
  tags = {
     Name = "DB subnet group"}
}


resource "aws_db_instance" "db_instance" {
  allocated_storage      = var.db_allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.db_sg.name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_user
  password               = var.db_password

  vpc_security_group_ids = [var.db_security_group_id]
  multi_az               = true
  skip_final_snapshot    = true 

  tags = {
    Name = "RDS DB"
  }
}
