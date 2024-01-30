# Load Balancer
resource "aws_lb" "coder_nlb" {
  name                             = "coder-nlb"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = aws_subnet.public_subnet[*].id
  enable_cross_zone_load_balancing = true

  enable_deletion_protection = false

  tags = {
    Name = "coder-nlb"
  }
}

# Target groups for Load Balancer
resource "aws_lb_target_group" "coder_target_group" {
  name     = "coder-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.coder_vpc.id

  health_check {
    protocol = "HTTP"
  }
}

# Load Balancer listenet
resource "aws_lb_listener" "coder_listener" {
  load_balancer_arn = aws_lb.coder_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.coder_target_group.arn
  }
}
