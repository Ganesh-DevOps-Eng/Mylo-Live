# Load Balancer Target Group
resource "aws_lb_target_group" "my_target_group" {
  name     = "${var.project_name}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.VPC-Module.vpc_id

  health_check {
    path     = "/"
    protocol = "HTTP"
    port     = "traffic-port"
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Load Balancer
resource "aws_lb" "my_load_balancer" {
  name               = "${var.project_name}-load-balancer"
  load_balancer_type = "application"
  subnets            = module.VPC-Module.subnet-public[*]
  security_groups    = [module.VPC-Module.alb_sg]

  tags = {
    Name = "${var.project_name}-load-balancer"
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "my_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
  depends_on = [
    aws_lb_listener.https_listener
  ]
}


resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  #certificate_arn   = data.aws_acm_certificate.my_certificate.arn  # Use the valid ACM certificate ARN here
  certificate_arn = aws_iam_server_certificate.self_signed_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group.id
  }
}

  # depends_on = [
  #   # aws_acm_certificate_validation.acm_certificate_validation
  #   aws_acm_certificate.my_certificate.arn
  # ]

