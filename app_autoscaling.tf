resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_cluster_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
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

      metric_interval_lower_bound = 0
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
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }

  }
}