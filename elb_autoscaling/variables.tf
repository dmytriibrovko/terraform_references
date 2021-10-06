variable "vpc_id" {
  type        = string
  description = " VPC id"
}

variable "tags" {}

variable "launch_configuration_name" {
  type    = string

}

variable "ssl_policy" {}
variable "certificate_arn" {}
variable "public_subnet" {}

variable "auto_scaling_group_name" {
  type    = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "elb_name" {
  type    = string
  default = "autoscallinggroupelb"
}

variable "instance_sg_name" {}
variable "instance_port" {}
variable "allow_ports_instance" {}
variable "cidr_blocks_instance" {}
variable "iam_instance_profile" {}
variable "key_name" {}
variable "volume_size" {}
variable "elb_sg_name" {}
variable "allow_ports_elb" {}
variable "cidr_blocks_elb" {}
variable "health_check_target" {}
variable "lb_port" {}
variable "lb_protocol" {}
variable "max_size" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "subnets_app" {}