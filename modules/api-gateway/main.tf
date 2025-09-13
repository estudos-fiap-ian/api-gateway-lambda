resource "aws_apigatewayv2_api" "lambda" {
  name          = var.api_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = var.stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}



resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = var.log_retention_days
}

# Register endpoint
resource "aws_apigatewayv2_integration" "register" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = var.register_lambda_invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "register" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /register"
  target    = "integrations/${aws_apigatewayv2_integration.register.id}"
}

# Login endpoint
resource "aws_apigatewayv2_integration" "login" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = var.login_lambda_invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "login" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /login"
  target    = "integrations/${aws_apigatewayv2_integration.login.id}"
}


resource "aws_lambda_permission" "api_gw_register" {
  statement_id  = "AllowExecutionFromAPIGatewayRegister"
  action        = "lambda:InvokeFunction"
  function_name = var.register_lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gw_login" {
  statement_id  = "AllowExecutionFromAPIGatewayLogin"
  action        = "lambda:InvokeFunction"
  function_name = var.login_lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}