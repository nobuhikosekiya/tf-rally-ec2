terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    ec = {
      source  = "elastic/ec"
      version = "~> 0.12.0"
    }

    elasticstack = {
      source = "elastic/elasticstack",
      version = "~> 0.11.0"
    }
  }
}