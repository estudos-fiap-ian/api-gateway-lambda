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