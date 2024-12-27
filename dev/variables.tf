variable "bucket_name" {
  description = "The name of the S3 bucket for the static website"
  type        = string
}

# variable "region" {
#   description = "The AWS region to deploy resources into"
#   type        = string
#   default     = "us-east-1"
# }

variable "state_bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
}

variable "origin_bucket_name" {
  description = "The name of the origin bucket"
  type        = string
}

variable "default_root_object" {
  description = "The default root object for the CloudFront distribution"
  type        = string
  default     = "index.html"
}
# variable "bucket_url" {
#   description = "URL to access the S3 bucket website"
#   type        = string
  
# }