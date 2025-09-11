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

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "lambda_invoke_arn" {
  description = "ARN to invoke the Lambda function"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
}