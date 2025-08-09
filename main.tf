data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Create a security group for the EC2 instance to allow SSH access
resource "aws_security_group" "ec2" {
  name_prefix = "${var.prefix}-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # SSH access from anywhere (for demo purposes)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-security-group"
  }
}

# Use SSH key from local machine
resource "aws_key_pair" "my_key" {
  key_name   = "${var.prefix}-key"  
  public_key = file(var.ssh_public_key_path)

  tags = {
    Name = "${var.prefix}-key"
  }
}

# Create EBS volume
resource "aws_ebs_volume" "rally_data" {
  availability_zone = aws_instance.rally.availability_zone
  size              = var.ebs_volume_size
  type              = "gp3"
  iops              = 8000
  throughput        = 500

  tags = {
    Name = "${var.prefix}-rally-data"
  }
}

# Attach EBS volume to EC2 instance
resource "aws_volume_attachment" "rally_data" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.rally_data.id
  instance_id = aws_instance.rally.id
}

# Create the EC2 instance
resource "aws_instance" "rally" {
  ami                    = var.ec2_ami_id
  instance_type          = var.ec2_instance_type
  vpc_security_group_ids = [aws_security_group.ec2.id]
  key_name              = aws_key_pair.my_key.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 10
    encrypted   = true
  }

  user_data = templatefile("${path.module}/setup.sh", {
    ES_API_KEY = var.elastic_api_key
    ES_HOST    = var.elasticsearch_url
  })

  tags = {
    Name = "${var.prefix}-rally"
  }
}