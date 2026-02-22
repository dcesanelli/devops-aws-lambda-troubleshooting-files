# Broken Terraform and Lambda Project

This is a project that has issues with Terraform and a simple AWS Lambda function.

## Setup

1. Fork this repository.
2. Clone your fork.
3. Run `terraform init` and `terraform apply` in the `/` directory.
4. Debug and fix the issues.

## Run

1. Execute `terraform apply` to create the resources.
2. Test the Lambda function to make sure it's working as expected.

# Fixes

It has been updated to resolve the deployment issues including bucket naming conflicts, S3 ACL permission errors, and missing deployment artifacts.

## Issues Resolved

The following fixes were implemented:

- **Changed folder structure**: I created a new folder structure to match the Task 3 description:

  project-root/
  |-- terraform/
  | |-- main.tf
  | |-- variables.tf
  | |-- outputs.tf
  |-- lambda/
  | |-- handler.py
  | |-- requirements.txt
  |-- README.md

- **Dynamic Bucket Naming**: Replaced the static bucket name with a dynamic one using `data.aws_caller_identity` to append the AWS Account ID. This ensures the S3 bucket name is globally unique.
- **S3 Security & ACLs**: Removed the deprecated `acl = "private"` argument that caused `AccessControlListNotSupported` errors. Added an `aws_s3_bucket_public_access_block` resource to enforce private access securely.
- **Removed requirements.txt**: `boto3` is included in lambda, so there is no need to run `pip install` to install dependencies before creating zip file
- **Zip python file**: Integrated the `archive_file` data source to automatically ZIP the `handler.py` file into `lambda_function_payload.zip` during the Terraform execution.
- **File upload**: Added an `aws_s3_object` resource to handle the upload of the deployment package to S3.
- **Explicit Dependencies**: Added a `depends_on` block to the Lambda function resource to ensure the S3 object is fully uploaded before AWS attempts to create the function.

## Test

- **Run init and apply steps**

```
cd terraform
terraform init
terraform apply
```

- **After applying changes tested the my_lambda lambda function with this output**

```
aws lambda invoke --region us-east-1 --function-name my_lambda response.json
cat response.json

{"statusCode": 200, "body": "\"Hello from Lambda!\""}%
```
