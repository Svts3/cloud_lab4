terraform {
  cloud {
    organization = "svsts3" 
    workspaces {
      name = "lab4-workspace" 
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.26.0"
    }
  }

}

provider "aws" {
  region = "eu-central-1"
}



resource "aws_ecr_repository" "ecr_repository" {
  name         = "back-end-repository"
  force_delete = true
}
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
          { "name" : "db_username", "value" : "admin" },
          { "name" : "db_password", "value" : "admin1224" }
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
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_cluster_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}


resource "aws_ecs_service" "ecs_cluster_service" {
  name = "back-end-service"
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

resource "aws_appautoscaling_policy" "ecs_service_auto_scaling_up" {
  name               = "scale_up_policy"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  policy_type        = "StepScaling"
  step_scaling_policy_configuration {
    metric_aggregation_type = "Average"
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    step_adjustment {
      metric_interval_lower_bound = 50
      scaling_adjustment          = 1
    }
  }
}
resource "aws_appautoscaling_policy" "ecs_service_auto_scaling_down" {
  name               = "scale_down_policy"
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_target.id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  policy_type        = "StepScaling"
  step_scaling_policy_configuration {
    metric_aggregation_type = "Average"
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    step_adjustment {
      metric_interval_upper_bound = 20
      scaling_adjustment          = -1
    }
  }
}
