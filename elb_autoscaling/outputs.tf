output "ami_id" {
  value = aws_launch_template.launch_template.image_id
}

output "launch_template_latest_version" {
  value = aws_launch_template.launch_template.latest_version
}