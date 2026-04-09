output "bucket_name" {
  description = "Name of the photos S3 bucket"
  value       = aws_s3_bucket.photos.id
}

output "bucket_arn" {
  description = "ARN of the photos S3 bucket"
  value       = aws_s3_bucket.photos.arn
}

output "cloudfront_domain" {
  description = "CloudFront distribution domain name — use this as the base URL for photos"
  value       = aws_cloudfront_distribution.photos.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.photos.id
}
