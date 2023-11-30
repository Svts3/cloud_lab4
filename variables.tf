variable "ecr_repository_name" {
  type    = string
  default = "back-end-repository"
}

variable "db_username" {
  type      = string
  sensitive = true

}
variable "db_password" {
  type      = string
  sensitive = true

}




