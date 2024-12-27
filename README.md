# Static Website Hosting with S3 and CloudFront Using Terraform

## Overview

This project sets up an S3 bucket to host a static website and a CloudFront distribution to serve the content with low latency and high availability.

## Prerequisites

- Terraform installed on your local machine.
- AWS CLI configured with appropriate permissions.

### Introduction
This project demonstrates how to set up a static website hosting solution using AWS S3 and CloudFront, managed through Terraform. The configuration includes:

* **Terraform**: An infrastructure as code tool that allows you to define and provision infrastructure using a high-level configuration language.

* **S3 Bucket**: Hosts the static website files.
CloudFront Distribution: Provides a content delivery network (CDN) to serve the website with low latency and high availability.

* **Remote Backend**: Uses S3 for storing the Terraform state file and DynamoDB for state locking and consistency.

**Key Components**

1. **Terraform**: Manages the entire infrastructure setup, ensuring reproducibility and version control.

2. **S3 Bucket**: Configured to host a static website with an index and error document.

3. **CloudFront Distribution**:
   * **Origins**: Points to the S3 bucket.
Default Cache Behavior: Configures caching and viewer protocol policies.

   * **Geo-Restrictions**: Currently set to allow access from all locations.
   * **Viewer Certificate**: Uses the default CloudFront certificate for HTTPS.

**Remote Backend**:

   * **S3**: Stores the Terraform state file, enabling collaboration and state management.

   *  **DynamoDB**: Provides state locking and consistency, preventing concurrent modifications to the state file.

   * **Origin Access Identity (OAI)**: Restricts direct access to the S3 bucket, allowing only CloudFront to fetch the content.

This setup ensures a scalable, secure, and performant static website hosting solution, with robust state management and collaboration capabilities provided by Terraform's remote backend.



## Project Structure
```
s3-static-website/
|── backend
│   ├── main.tf
│   ├── output.tf
│   ├── terraform.tfstate
│   ├── terraform.tfvars
│   └── variables.tf  
├── modules/
│   └── s3-static-website/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── envs/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
├── backend.tf
├── provider.tf
└── variables.tf
```

## Configuration Files

### `envs/dev/main.tf`

This file contains the main Terraform configuration for the development environment.

```terraform
module "s3_static_website" {
  source = "../../module/s3-website"

  bucket_name       = var.bucket_name
  origin_bucket_name = var.origin_bucket_name
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = module.s3_static_website.bucket_url
    origin_id   = "S3-${module.s3_static_website.bucket_name}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for S3 website"
  default_root_object = var.default_root_object

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${module.s3_static_website.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access Identity for S3 bucket"
}
```

### `envs/dev/outputs.tf`

This file defines the outputs for the development environment.

```terraform
output "s3_bucket_website_endpoint" {
  description = "The website endpoint of the S3 bucket"
  value       = module.s3_static_website.website_endpoint
}

output "bucket_url" {
  description = "The website endpoint of the S3 bucket"
  value       = module.s3_static_website.bucket_url
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket hosting the website"
  value       = module.s3_static_website.bucket_name
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
}
``` 

### `envs/dev/terraform.tfvars`

This file contains the variable values for the development environment.

```terraform

bucket_name       = "my-website-bucket"
origin_bucket_name = "my-static-website-bucket"

```

### `envs/dev/variables.tf `

This file defines the variables for the development environment.

```terraform
variable "bucket_name" {
  description = "The name of the S3 bucket"
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
```

### `module/s3-website/main.tf`

This file contains the main Terraform configuration for the S3 website module.

```terraform

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name = var.bucket_name
  }
}
```

### `module/s3-website/outputs.tf`

This file defines the outputs for the S3 website module.

```terraform
output "website_endpoint" {
  description = "The website endpoint of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.website_endpoint
}

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.bucket
}

output "bucket_url" {
  description = "The URL of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.website_endpoint
}
```

### `module/s3-website/variables.tf`

This file defines the variables for the S3 website module.

```terraform
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
```

### Usage
1. **Initialize Terraform**: Run the following command to initialize Terraform.

```terraform
terraform init
```
2. **Validate Configuration**: Run the following command to validate the Terraform configuration.

```terraform
terraform validate
```
3. **Apply Configuration**: Run the following command to apply the Terraform configuration.

```terraform
terraform apply
```
### Outputs

After applying the configuration, you will get the following outputs:

* **S3 Bucket Website Endpoint**: The website endpoint of the S3 bucket.
* **Bucket URL**: The URL of the S3 bucket.
* **S3 Bucket Name**: The name of the S3 bucket hosting the website.
* CloudFront Domain Name: The domain name of the CloudFront distribution.

### Images
**CloudFront Domain Name**
![cloud front domain name](image-1.png)

**S3 Bucket URL**
![s3 bucket url](image-2.png)


### Conclusion

This project provides a comprehensive solution for hosting a static website using AWS S3 and CloudFront, managed through Terraform. By leveraging Terraform's infrastructure as code capabilities, you can easily define, provision, and manage your infrastructure in a reproducible and version-controlled manner. The use of a remote backend with S3 and DynamoDB ensures robust state management and collaboration.

Key benefits of this setup include:

* **Scalability**: CloudFront's CDN capabilities ensure low latency and high availability for your website.

* **Security**: The Origin Access Identity (OAI) restricts direct access to the S3 bucket, allowing only CloudFront to fetch the content.

* **Manageability**: Terraform simplifies the management of your infrastructure, making it easy to apply changes and track the state of your resources.

By following this guide, you can set up a secure, scalable, and performant static website hosting solution on AWS.
#   s 3 - s t a t i c - w e b i s t e - w i t h - c l o u f r o n t - u s i n g - t e r r a f o r m  
 #   s 3 - s t a t i c - w e b i s t e - w i t h - c l o u f r o n t - u s i n g - t e r r a f o r m  
 