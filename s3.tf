provider "aws" {
 
   region     = "us-east-2"
}


resource "aws_kms_key" "ajckey" {
  description             = "This key is used to encrypt bucket objects"
  #deletion_window_in_days = 10
}

resource "aws_s3_bucket" "bootcamp30-122080-atem" {
  bucket = "bootcamp30-122080-atem"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ajc-sse" {
  bucket = aws_s3_bucket.bootcamp30-122080-atem.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.ajckey.arn
      sse_algorithm     = "aws:kms"  # "AES256"
    }
  }
}
