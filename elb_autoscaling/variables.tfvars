tags = {
  APPLICATION = "",
  ENVIRONMENT = "NONPROD",
  CUSTOMER    = "",
  STACK       = "Develop"
}

#-----     EC2      ---------
launch_configuration_name = "dev"
auto_scaling_group_name   = "dev-stand-autoscaling"
instance_type             = "t3.xlarge"
instance_sg_name          = "dev-sg"
instance_port             = "80"
allow_ports_instance      = ["80"]
cidr_blocks_instance      = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
subnets_app               = [""]
key_name                  = "nonprod"
volume_size               = 80
iam_instance_profile      = "arn:aws:iam::??:instance-profile/profile"
max_size                  = 3
min_size                  = 1
desired_capacity          = 1
#---- LB -------
elb_name            = "dev"
elb_sg_name         = "dev"
allow_ports_elb     = ["80", "443"]
cidr_blocks_elb     = ["0.0.0.0/0"]
health_check_target = "HTTP:80/health-status"
lb_port             = "80"
lb_protocol         = "http"
certificate_arn     = "arn:aws:acm:us-east-1:"
ssl_policy          = "ELBSecurityPolicy-2016-08"
public_subnet       = []
