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


variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}



variable "register_lambda_invoke_arn" {
  description = "ARN to invoke the Register Lambda function"
  type        = string
}

variable "register_lambda_function_name" {
  description = "Name of the Register Lambda function"
  type        = string
}

variable "login_lambda_invoke_arn" {
  description = "ARN to invoke the Login Lambda function"
  type        = string
}

variable "login_lambda_function_name" {
  description = "Name of the Login Lambda function"
  type        = string
}