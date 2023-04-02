# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Adorerscenacle VPC Name"
  type        = string 
  default     =  "adorerscenacle-vpc"
}