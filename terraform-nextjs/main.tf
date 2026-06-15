terraform {
    required_version = ">= 1.0"

    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 6.0"
        }
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