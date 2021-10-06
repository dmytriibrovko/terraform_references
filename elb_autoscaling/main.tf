resource "aws_launch_template" "launch_template" {
  name_prefix            = var.launch_configuration_name
  image_id               = data.aws_ami.dev_ami.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [data.terraform_remote_state.vpc_alxnonprod_state.outputs.sg_generic_internal_all_id]
  user_data              = filebase64("user_data.sh")
  iam_instance_profile {
    arn = var.iam_instance_profile
  }
  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.volume_size
    }
  }
  ebs_optimized = true
  tag_specifications {
    resource_type = "instance"

    tags = var.tags
  }

}

resource "aws_security_group" "elb_security_group" {
  name_prefix = var.elb_sg_name
  vpc_id      = data.terraform_remote_state.vpc_alxnonprod_state.outputs.generic_vpc_id

  dynamic "ingress" {
    for_each = var.allow_ports_elb
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.cidr_blocks_elb
    }
  }
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_lb" "loadbalancer" {
  name               = var.elb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.elb_security_group.id}","${data.terraform_remote_state.vpc_alxnonprod_state.outputs.sg_public_alb_id}"]
  subnets            = data.terraform_remote_state.vpc_alxnonprod_state.outputs.generic_public_subnet_id

  enable_deletion_protection = true

  tags = var.tags
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target.arn
  }
}

resource "aws_lb_listener" "redirect" {
  load_balancer_arn = aws_lb.loadbalancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "lb_target" {
  port        = var.instance_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.terraform_remote_state.vpc_alxnonprod_state.outputs.generic_vpc_id
  health_check {
    enabled   = true
    port      = "traffic-port"
    protocol  = "HTTP"
  }
}


resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling_group_config.id
  alb_target_group_arn   = aws_lb_target_group.lb_target.arn
  depends_on = [aws_autoscaling_group.autoscaling_group_config,aws_launch_template.launch_template]
}

resource "aws_autoscaling_group" "autoscaling_group_config" {
  name                      = "${var.auto_scaling_group_name}-${aws_launch_template.launch_template.latest_version}"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  vpc_zone_identifier       = data.terraform_remote_state.vpc_alxnonprod_state.outputs.generic_app_subnet_id
  target_group_arns         = [aws_lb_target_group.lb_target.arn]

  launch_template {
    id      = aws_launch_template.launch_template.id
    version = aws_launch_template.launch_template.latest_version
  }

  lifecycle {
    create_before_destroy = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
    triggers = ["tag"]
  }

}