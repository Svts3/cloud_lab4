output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}
output "rds_database_name" {
  value = aws_db_instance.rds_instance.db_name
}
output "aws_lb_dns_name" {
  value = aws_lb.load_balancer.dns_name
}
