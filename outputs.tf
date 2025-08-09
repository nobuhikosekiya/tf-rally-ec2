# Output the instance's public IP address for convenience
output "instance_public_ip" {
  description = "Public IP address of the Rally EC2 instance"
  value       = aws_instance.rally.public_ip
}

output "instance_id" {
  description = "ID of the Rally EC2 instance"
  value       = aws_instance.rally.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.ec2.id
}

output "ssh_connection" {
  description = "SSH connection command"
  value       = "ssh rally@${aws_instance.rally.public_ip}"
}