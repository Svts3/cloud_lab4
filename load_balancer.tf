resource "aws_lb" "load_balancer" {
  name               = "ecs-load-balancer"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = [aws_subnet.subnet-a.id, aws_subnet.subnet-b.id, aws_subnet.subnet-c.id]
}

resource "aws_lb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.load_balancer_target_group.arn
    type             = "forward"
  }
}
resource "aws_lb_target_group" "load_balancer_target_group" {
  name        = "ecs-target-group"
  target_type = "ip"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  stickiness {
    enabled = true
    cookie_duration = 3600
    type = "lb_cookie"
  }
  health_check {
    path     = "/health-check"
    port     = 8080
    protocol = "HTTP"
  }
}
