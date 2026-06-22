# Terraform Portfolio Project

A static **Next.js** site deployed to AWS as **infrastructure as code** — reproducible from a single `terraform apply`, no click-ops.

**Live:** https://d19j21iocmn17k.cloudfront.net

## Architecture

Files are stored in a **private S3 bucket** and served globally over HTTPS through **CloudFront** (AWS's CDN). The bucket is never public. CloudFront reaches it through an **Origin Access Control (OAC)** with SigV4 signing, and a bucket policy grants `s3:GetObject` to *only this specific distribution* — one controlled entry point instead of two.

## Why private S3 + OAC

The common tutorial pattern makes the bucket public. That leaves a second front door: anyone who learns the bucket address bypasses the CDN entirely. Keeping the bucket private and giving CloudFront its own identity closes that door. Trade-off: ~20% more Terraform (OAC resource, scoped bucket policy, four public-access blocks) in exchange for a single entry point and least-privilege access.

## Getting Started

### Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.0` (built with `v1.15.4`)
- An AWS account with credentials configured locally (via `aws configure`, environment variables, or an SSO profile)
- IAM permissions for S3, CloudFront, and IAM actions
- Your static site's built output (Next.js `out/` directory) ready to upload

### Deploy

```bash
# 1. Clone and enter the repo
git clone https://github.com/ericcoufal/terraform-portfolio-project.git
cd terraform-portfolio-project/terraform-nextjs

# 2. Initialize — downloads the AWS provider
terraform init

# 3. Preview what will be created (no changes made yet)
terraform plan

# 4. Build the infrastructure
terraform apply

# 5. Grab the outputs (CloudFront URL, bucket name)
terraform output
```

After `apply`, upload your site files to the bucket, then load the CloudFront URL from `terraform output`. Note: CloudFront distributions take a few minutes to deploy globally on first creation.

### Tear down

```bash
terraform destroy
```

> **Note:** The S3 bucket name is globally unique — `ericcoufal-portfolio-site` is taken. Change the `bucket` value in `main.tf` to something unique before deploying your own copy.

## Verified secure

| Request               | Result          |
| --------------------- | --------------- |
| Through CloudFront    | `200 OK`        |
| Direct to the S3 URL  | `403 Forbidden` |

Same file, two doors, two answers.

## Stack

- Terraform `v1.15.4`
- `hashicorp/aws` `v6.50.0`
- Region: `us-east-1`

## Full write-up

The reasoning behind every decision, including what I'd do differently, is in my Medium blog post.