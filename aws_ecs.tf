data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}
resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "back-end-task-definition-family"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  container_definitions = jsonencode(
    [
      {
        name      = "back-end-container"
        image     = "${aws_ecr_repository.ecr_repository.repository_url}:latest"
        essential = true
        portMappings = [
          {
            containerPort = 8080
            hostPort      = 8080
          }
        ],
        environment = [
          { "name" : "db_url", "value" : "jdbc:mysql://${aws_db_instance.rds_instance.endpoint}/lab_database" },
          { "name" : "db_username", "value" : "${var.db_username}" },
          { "name" : "db_password", "value" : "${var.db_password}" }
        ]
      },

    ]
  )

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name       = "back-end-cluster"
  depends_on = [aws_ecs_task_definition.ecs_task_definition]


}

resource "aws_ecs_service" "ecs_cluster_service" {
  name = "back-end-service"
  deployment_minimum_healthy_percent = 0
  force_new_deployment = true
  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_security_group.id]
    subnets          = [aws_subnet.subnet-a.id, aws_subnet.subnet-b.id, aws_subnet.subnet-c.id]
  }
  load_balancer {
    container_name   = "back-end-container"
    container_port   = 8080
    target_group_arn = aws_lb_target_group.load_balancer_target_group.arn
  }
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  depends_on      = [aws_ecs_cluster.ecs_cluster]
  launch_type     = "FARGATE"
  desired_count   = 1
}