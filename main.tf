terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.90.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.1"
    }
  }
}

resource "random_bytes" "unique-id" {
  length = 10
}
provider "aws" {
    region = var.region
    profile = "default"
}

resource "aws_s3_bucket" "bucket-1" {
  bucket = "${random_bytes.unique-id.hex}-bucket"
}

resource "aws_s3_bucket_public_access_block" "giving-public-access-to-bucket" {
  bucket= aws_s3_bucket.bucket-1.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_object" "bucket-data"{
  bucket = aws_s3_bucket.bucket-1.id
  count = 2
  key = var.data-of-web[count.index]
  source = var.data-of-web[count.index]
  content_type = "text/html"
}

resource "aws_s3_object" "bucket-data1"{
  bucket = aws_s3_bucket.bucket-1.id
  key = "./styles.css"
  source = "./styles.css"
  content_type = "text/css"
}

resource "aws_s3_bucket_policy" "allow_access_from-internet" {
  bucket = aws_s3_bucket.bucket-1.id
  policy = jsonencode(
    {
    Version = "2012-10-17",
    Statement= [
        {
            Effect = "Allow",
            Principal = "*",
            Action = "s3:GetObject",
            Resource = "${aws_s3_bucket.bucket-1.arn}/*"
        }
    ]
}
  )

  
}

resource "aws_s3_bucket_website_configuration" "enable-static-web" {
  bucket = aws_s3_bucket.bucket-1.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
  
}

output "website_url" {
  description = "Please find the website url:"
  value= aws_s3_bucket_website_configuration.enable-static-web.website_endpoint
}