resource "aws_ecr_repository" "ecr_repository" {
  name         = "back-end-repository"
  force_delete = true
}