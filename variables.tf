variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS Profile to use for credentials"
  type        = string
  default     = "default"
}

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "default_tags" {
  description = "AWS default tags for resources"
  type        = map(string)
  default     = {}
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "m5.large"
}

variable "ec2_ami_id" {
  description = "EC2 AMI ID"
  type        = string
  default     = "ami-0599b6e53ca798bb2"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "ebs_volume_size" {
  description = "Size of EBS volume in GB"
  type        = number
  default     = 100
}

variable "elastic_api_key" {
  description = "Elastic Cloud API key for Rally"
  type        = string
  sensitive   = true
}

variable "elasticsearch_url" {
  description = "Elasticsearch URL for Rally"
  type        = string
}