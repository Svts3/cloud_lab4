resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name                = "scale-up-alarm"
  alarm_actions             = [aws_appautoscaling_policy.ecs_service_auto_scaling_up.arn]
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 50
  insufficient_data_actions = []
  dimensions = {
    "ClusterName" = aws_ecs_cluster.ecs_cluster.name
    "ServiceName" = aws_ecs_service.ecs_cluster_service.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name                = "scale-down-alarm"
  alarm_actions             = [aws_appautoscaling_policy.ecs_service_auto_scaling_down.arn]
  actions_enabled           = true
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 20
  insufficient_data_actions = []
  dimensions = {
    "ClusterName" = aws_ecs_cluster.ecs_cluster.name
    "ServiceName" = aws_ecs_service.ecs_cluster_service.name
  }
}