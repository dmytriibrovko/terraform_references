data "aws_ami" "dev_ami" {
  owners = ["self"]
  most_recent = true
  filter {
    name = "name"
    values = ["-*"]
  }
}

data "terraform_remote_state" "vpc_alxnonprod_state" {
  backend = "s3"
  config = {
    bucket = ""
    key = "network/terraform.tfstate"
    region = "us-east-1"
    profile = ""
  }
}