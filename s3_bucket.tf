resource "aws_s3_bucket" "new_bucket" {
  bucket = "tf_github_action_bucket"

  object_lock_enabled = false

  tags = {
    Environment = "Prod"
  }
}