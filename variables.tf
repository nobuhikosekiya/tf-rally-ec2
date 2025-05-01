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

variable "elastic_api_key" {
  description = "Elastic Cloud API key for Filebeat"
  type        = string
  sensitive   = true
}

variable "elasticsearch_url" {
  description = "Elasticsearch URL for Elastic Agent"
  type        = string
}