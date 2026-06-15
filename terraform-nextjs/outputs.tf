output "cloudfront_url" {
    description = "The CloudFront URL of the deployed site"
    value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "bucket_name" {
    description = "The name of the S3 bucket"
    value       = aws_s3_bucket.website.id
}