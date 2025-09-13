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

module "cognito" {
  source = "./modules/cognito"

  user_pool_name = var.cognito_user_pool_name
  environment    = var.environment
  callback_urls  = var.cognito_callback_urls
  logout_urls    = var.cognito_logout_urls
}


module "lambda_register" {
  source = "./modules/lambda"

  function_name         = "RegisterUser"
  runtime               = var.runtime
  handler               = "register.handler"
  log_retention_days    = var.log_retention_days
  lambda_role_name      = var.lambda_role_name
  cognito_user_pool_id  = module.cognito.user_pool_id
  cognito_user_pool_arn = module.cognito.user_pool_arn
  cognito_client_id     = module.cognito.user_pool_client_id
  jwt_secret_key        = var.jwt_secret_key
  source_dir            = "auth"
  source_file           = "register"
}

module "lambda_login" {
  source = "./modules/lambda"

  function_name         = "LoginUser"
  runtime               = var.runtime
  handler               = "login.handler"
  log_retention_days    = var.log_retention_days
  lambda_role_name      = var.lambda_role_name
  cognito_user_pool_id  = module.cognito.user_pool_id
  cognito_user_pool_arn = module.cognito.user_pool_arn
  cognito_client_id     = module.cognito.user_pool_client_id
  jwt_secret_key        = var.jwt_secret_key
  source_dir            = "auth"
  source_file           = "login"
}

module "lambda_anonymous" {
  source = "./modules/lambda"

  function_name         = "AnonymousLogin"
  runtime               = var.runtime
  handler               = "anonymous.handler"
  log_retention_days    = var.log_retention_days
  lambda_role_name      = var.lambda_role_name
  cognito_user_pool_id  = module.cognito.user_pool_id
  cognito_user_pool_arn = module.cognito.user_pool_arn
  cognito_client_id     = module.cognito.user_pool_client_id
  jwt_secret_key        = var.jwt_secret_key
  source_dir            = "auth"
  source_file           = "anonymous"
}

module "api_gateway" {
  source = "./modules/api-gateway"

  api_name           = var.api_name
  stage_name         = var.stage_name
  log_retention_days = var.log_retention_days

  # Auth endpoints
  register_lambda_invoke_arn     = module.lambda_register.lambda_invoke_arn
  register_lambda_function_name  = module.lambda_register.lambda_function_name
  login_lambda_invoke_arn        = module.lambda_login.lambda_invoke_arn
  login_lambda_function_name     = module.lambda_login.lambda_function_name
  anonymous_lambda_invoke_arn    = module.lambda_anonymous.lambda_invoke_arn
  anonymous_lambda_function_name = module.lambda_anonymous.lambda_function_name
}
