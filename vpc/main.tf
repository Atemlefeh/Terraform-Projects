# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

locals {
  tag_name = "ajc-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 3
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
  name = var.vpc_name #"adorerscenacle-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "adorerscenacle/${local.tag_name}" = "shared"
    "adorerscenacle/role/elb"                      = 1
  }

  private_subnet_tags = {
    "adorerscenacle/${local.tag_name}" = "shared"
    "adorerscenacle/role/internal-elb"             = 1
  }
}
