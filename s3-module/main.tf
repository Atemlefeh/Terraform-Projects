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

# Customer managed KMS key
###########################
resource "aws_kms_key" "kms_s3_key" {
    description             = "Key to protect S3 objects"
    key_usage               = "ENCRYPT_DECRYPT"
    deletion_window_in_days = 7
    is_enabled              = true
}

resource "aws_kms_alias" "kms_s3_key_alias" {
    name          = "alias/s3-key"
    target_key_id = aws_kms_key.kms_s3_key.key_id
}

# Bucket creation
########################
resource "aws_s3_bucket" "ajc_bucket" {
  bucket = var.bucket_name
}

# Bucket private access
##########################
resource "aws_s3_bucket_acl" "ajc_bucket_acl" {
  bucket = aws_s3_bucket.ajc_bucket.id
  acl    = "private"
}

# Enable bucket versioning
#############################
resource "aws_s3_bucket_versioning" "ajc_bucket_versioning" {
  bucket = aws_s3_bucket.ajc_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server access logging
#################################
resource "aws_s3_bucket_logging" "ajc_bucket_logging" {
  bucket = aws_s3_bucket.ajc_bucket.id

  target_bucket = var.access_logging_bucket_name
  target_prefix = "${var.bucket_name}/"
}

# Enable default Server Side Encryption
##########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "ajc_bucket_sse" {
  bucket = aws_s3_bucket.ajc_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.kms_s3_key.arn
        sse_algorithm     = "aws:kms"
    }
  }
}

# Creating Lifecycle Rule
############################
resource "aws_s3_bucket_lifecycle_configuration" "ajc_bucket_lifecycle_rule" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.ajc_bucket_versioning]

  bucket = aws_s3_bucket.ajc_bucket.bucket

  rule {
    id = "basic_config"
    status = "Enabled"

    filter {
      prefix = "config/"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# Disabling bucket
# public access
########################
resource "aws_s3_bucket_public_access_block" "ajc_bucket_access" {
  bucket = aws_s3_bucket.ajc_bucket.id

  # Block public access
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
