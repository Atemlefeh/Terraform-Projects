#################################################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    #  version = "~> 4.0.0"
    }
  }

 # required_version = ">= 0.15"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

resource "aws_kms_key" "ajckey" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "ajcbucket" {
  bucket = "bootcamp30_ajc"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ajc-sse" {
  bucket = aws_s3_bucket.ajcbucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.ajckey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
