module "s3_static_website" {
  source = "../../module/s3-website"

  bucket_name = var.bucket_name
  origin_bucket_name = var.origin_bucket_name
}



resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = module.s3_static_website.website_endpoint
    origin_id   = "S3-${module.s3_static_website.bucket_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
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