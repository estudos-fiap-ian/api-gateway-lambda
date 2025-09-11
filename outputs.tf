output "function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.lambda_function_name
}

output "base_url" {
  description = "Base URL for API Gateway stage"
  value       = module.api_gateway.base_url
}

output "api_id" {
  description = "ID of the API Gateway"
  value       = module.api_gateway.api_id
}
