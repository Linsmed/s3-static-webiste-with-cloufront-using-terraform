
terraform {
  backend "s3" {
    bucket         = "ejibode-state-bucket"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ejibode-state-lock-table"
    encrypt        = true
  
  }
}