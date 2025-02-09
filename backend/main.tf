terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region = var.region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


#create DynamoDB Table for Locking
resource "aws_dynamodb_table" "terraform_locks" {
   name = "ejibode-state-lock-table"
   billing_mode = "PAY_PER_REQUEST"
   hash_key = "LockID"
   attribute {
     name = "LockID"
     type = "S"
 }
}



resource "aws_s3_bucket" "state" {
  bucket = "ejibode-state-bucket"

  tags = {
    Name = "My bucket"
  }
}


# resource "aws_dynamodb_table" "terraform_state_lock" {
#   name           = var.dynamodb_table_name
#   read_capacity  = 1
#   write_capacity = 1
#   hash_key       = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }
