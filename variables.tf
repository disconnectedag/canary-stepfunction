# variable "aws_access_key" {
#     type = string
#     description = "AWS Access Key"
#     sensitive = true
# }

# variable "aws_secret_key" {
#     type = string
#     description = "AWS Secret Key"
#     sensitive = true
# }

# variable "aws_region" {
#     type = string
#     description = "AWS Region for resources"
#     default = "us-east-1"
# }

variable "lambda_runtime" {
    type = string
    description = "Lambda runtime"
    default = "python3.9"
}