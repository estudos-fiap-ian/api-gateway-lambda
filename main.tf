terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.2"
    }
  }
  backend "s3" {
    bucket = "api-gateway-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
  required_version = "~> 1.2"
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      hashicorp-learn = "lambda-api-gateway"
    }
  }
}

module "lambda" {
  source = "./modules/lambda"

  function_name      = var.function_name
  runtime            = var.runtime
  handler            = var.handler
  log_retention_days = var.log_retention_days
  lambda_role_name   = var.lambda_role_name
}

module "api_gateway" {
  source = "./modules/api-gateway"

  api_name             = var.api_name
  stage_name           = var.stage_name
  route_key            = var.route_key
  log_retention_days   = var.log_retention_days
  lambda_invoke_arn    = module.lambda.lambda_invoke_arn
  lambda_function_name = module.lambda.lambda_function_name
}
