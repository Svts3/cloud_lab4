resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds_subnte_group"
  subnet_ids = [
    aws_subnet.subnet-a.id, aws_subnet.subnet-b.id, aws_subnet.subnet-c.id
  ]

}
resource "aws_db_instance" "rds_instance" {
  identifier             = "terraform-database"
  allocated_storage      = 10
  db_name                = "lab_database"
  engine                 = "mysql"
  engine_version         = "8.0.33"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible    = true
  skip_final_snapshot    = true
}