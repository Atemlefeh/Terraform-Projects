variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "ajc-bucket"
}

variable "access_logging_bucket_name" {
  description = "S3 bucket name for access logging"
  type        = string
  default     = "ajc-logging-bucket"
}
