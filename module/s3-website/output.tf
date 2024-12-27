

output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.id
  
}

output "bucket_url" {
  description = "The URL of the S3 bucket"
  value       = aws_s3_bucket.website_bucket.website_endpoint
}



# output "cloudfront_distribution_id" {
#   description = "The ID of the CloudFront distribution"
#   value       = aws_cloudfront_distribution.website_distribution.id
# }

# output "cloudfront_distribution_domain_name" {
#   description = "The domain name of the CloudFront distribution"
#   value       = aws_cloudfront_distribution.website_distribution.domain_name
# }

output "website_endpoint" {
  description = "The website endpoint of the S3 bucket"
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
}
