provider "aws" {
  shared_credentials_files = ["~/.aws/credentials"]
  shared_config_files      = ["~/.aws/config"]
  profile                  = "default"
  region                   = "ap-northeast-2"
}

variable "vpc_id" {
  default = "vpc-4012ca2b"
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
  default     = ["subnet-eb37b090", "subnet-b037fddb"]
}

data "aws_vpc" "existing" {
  id = var.vpc_id
}

data "aws_subnets" "existing" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }
}
