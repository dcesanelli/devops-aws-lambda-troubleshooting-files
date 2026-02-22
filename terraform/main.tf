provider "aws" {
  region = "us-east-1"
}
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "my_bucket" {
  # Changed bucket name to include account ID to ensure uniqueness across AWS accounts.
  bucket = "my-super-cool-bucket${data.aws_caller_identity.current.account_id}"

  # Removed deprecated ACL configuration and added block public access settings to enhance security.
  # acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "my_bucket_access_block" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda"

  s3_bucket = aws_s3_bucket.my_bucket.bucket
  s3_key    = "lambda_function_payload.zip"

  handler = "handler.handler"
  runtime = "python3.8"

  role = aws_iam_role.iam_for_lambda.arn

  # Wait for the Lambda code to be uploaded to S3
  depends_on = [aws_s3_object.lambda_code]
}

# Lambda functioon needs to be zipped and uploaded to S3 before it can be created.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "../lambda/handler.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "lambda_function_payload.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}
