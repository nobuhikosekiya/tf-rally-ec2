
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

#----
# Create a security group for the EC2 instance to allow SSH access
resource "aws_security_group" "ec2" {
  name_prefix = "${var.prefix}-security-group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # OpenSSH to all IPs (for demo purposes; use a more restricted IP range in production)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_volume_attachment" "ebs_att" {
#   device_name = "/dev/xvdf"
#   volume_id   = "vol-0f1273270ae86c493"
#   instance_id = aws_instance.my_instance.id
# }

# 事前に作成されたSSHキーを使用
resource "aws_key_pair" "my_key" {
  key_name   = "${var.prefix}-key"   # 使用するキーの名前
  public_key = file("~/.ssh/id_rsa.pub") # ローカルの公開鍵ファイルのパス
}

# EBSボリュームを作成
resource "aws_ebs_volume" "example" {
  availability_zone = aws_instance.my_instance.availability_zone
  size              = 100  # ボリュームサイズ（GB）
  type              = "gp3"  # 高性能なGeneral Purpose SSD
  iops              = 8000
  throughput        = 500
  # lifecycle {
  #   prevent_destroy = true
  # }
}

# EBSボリュームをEC2インスタンスにアタッチ
resource "aws_volume_attachment" "example" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.example.id
  instance_id = aws_instance.my_instance.id
}

# Create the EC2 instance
resource "aws_instance" "my_instance" {
  tags = {
    Name = "${var.prefix}-rally"
  }
  ami           = "ami-0d52744d6551d851e"  # Replace with the desired EC2 AMI ID
  instance_type = "m5.large"  # Replace with your desired instance type
  vpc_security_group_ids = [aws_security_group.ec2.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 10
  }

  # Provide the path to your public SSH key on the local machine
  key_name = aws_key_pair.my_key.key_name # SSHキーを指定
  associate_public_ip_address = true

  user_data = templatefile("setup.sh", {
        ES_API_KEY  = "${var.elastic_api_key}"
        ES_HOST = "${var.elasticsearch_url}"
      })
}

# Output the instance's public IP address for convenience
output "instance_public_ip" {
  value = aws_instance.my_instance.public_ip
}