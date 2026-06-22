terraform {
    required_version = ">= 1.0"

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
    }

    backend "s3" {
            bucket          = "ericcoufal-tfstate-portfolio"
            key             = "portfolio/terraform.tfstate"
            region          = "us-east-1"
            use_lockfile    = true
            encrypt         = true
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_s3_bucket" "website" {
    bucket = "ericcoufal-portfolio-site"
}

resource "aws_s3_bucket_public_access_block" "website" {
    bucket = aws_s3_bucket.website.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "website" {
    name                                = "ericcoufal-portfolio-oac"
    description                         = "OAC for portfolio S3 bucket"
    origin_access_control_origin_type   = "s3"
    signing_behavior                    = "always"
    signing_protocol                    = "sigv4"   
}

resource "aws_cloudfront_distribution" "website" {
    enabled             = true
    is_ipv6_enabled     = true
    default_root_object = "index.html"
    comment             = "Portfolio site distribution"
    price_class         = "PriceClass_100"

    origin {
        domain_name                 = aws_s3_bucket.website.bucket_regional_domain_name
        origin_id                   = "s3-portfolio-origin"
        origin_access_control_id    = aws_cloudfront_origin_access_control.website.id
    }

    default_cache_behavior {
        allowed_methods         = ["GET", "HEAD"]
        cached_methods          = ["GET", "HEAD"]
        target_origin_id        = "s3-portfolio-origin"
        viewer_protocol_policy  = "redirect-to-https"
        compress                = true

        cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
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

resource "aws_s3_bucket_policy" "website" {
    bucket = aws_s3_bucket.website.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid         = "AllowCloudFrontServicePrincipalReadOnly"
                Effect      = "Allow"
                Principal   = {
                    Service = "cloudfront.amazonaws.com"
                }
                Action      = "s3:GetObject"
                Resource    = "${aws_s3_bucket.website.arn}/*"
                Condition   = {
                    StringEquals    = {
                        "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
                    }
                }
            }
        ]
    })
}