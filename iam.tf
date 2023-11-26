resource "aws_iam_role" "ecs_iam_role" {
  name = "ecs_iam_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy_attachment" "ecs_iam_policy_attachment" {
  name       = "ecs_iam_policy_attachment"
  roles      = [aws_iam_role.ecs_iam_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_iam_instance_profile" {
  name = "ecs_iam_instance_profile"
  role = aws_iam_role.ecs_iam_role.name
}