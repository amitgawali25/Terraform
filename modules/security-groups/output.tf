output "alb_security_group_id" {
  value = aws_security_group.alb_security_group.id
}
output "ec_security_group_id" {
  value = aws_security_group.ec_security_group.id
}
output "ec_bastion_security_group_id" {
  value = aws_security_group.ec_bastion_security_group.id
}
output "ec_be_security_group_id" {
  value = aws_security_group.ec_be_security_group.id
}
output "db_security_group_id" {
  value = aws_security_group.db_security_group.id
}