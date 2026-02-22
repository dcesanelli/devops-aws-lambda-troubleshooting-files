output "s3_bucket_name" {
  description = "The name of the S3 bucket created for storing Lambda code"
  value       = aws_s3_bucket.my_bucket.bucket
}

output "lambda" {
  description = "The AWS Lambda function created in this Terraform configuration."
  value       = aws_lambda_function.my_lambda.function_name
}

