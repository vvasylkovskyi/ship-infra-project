resource "aws_lb" "my_app" {
  name               = "my-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_alb.id]
  subnets            = var.subnets
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.my_app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_app.arn
  }

  depends_on = [var.acm_certificate_cert]
}

resource "aws_lb_target_group" "my_app" {
  name     = "my-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 15
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  depends_on = [aws_lb.my_app]
}

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  count = length(var.ec2_instance_ids)
  
  target_group_arn = aws_lb_target_group.my_app.arn
  target_id        = var.ec2_instance_ids[count.index]
  port             = 80
}

resource "aws_security_group" "my_alb" {
  name   = "Security Group for Application Load Balancer"
  vpc_id = var.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}