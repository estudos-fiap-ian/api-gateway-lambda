variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "HelloWorld"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "nodejs20.x"
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "hello.handler"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "lambda_role_name" {
  description = "IAM role name for Lambda execution"
  type        = string
  default     = "LabRole"
}

variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "serverless_lambda_gw"
}

variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "serverless_lambda_stage"
}

variable "route_key" {
  description = "Route key for the API Gateway route"
  type        = string
  default     = "GET /hello"
}
