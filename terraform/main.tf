terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.aws_region
  profile = "personal"
}

# DynamoDB 테이블 생성
resource "aws_dynamodb_table" "todo_table" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name        = "TodoTable"
    Environment = var.environment
    Project     = "TodoApp"
  }
}

# Lambda 함수를 위한 IAM 역할 생성
resource "aws_iam_role" "lambda_role" {
  name = "todo_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "TodoLambdaRole"
    Environment = var.environment
    Project     = "TodoApp"
  }
}

# Lambda 함수에 DynamoDB 접근 권한 부여
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "todo_lambda_dynamodb_policy"
  description = "Allow Lambda to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.todo_table.arn
      }
    ]
  })
}

# Lambda 함수에 CloudWatch Logs 접근 권한 부여
resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "todo_lambda_logging_policy"
  description = "Allow Lambda to log to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# IAM 정책 연결
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

# Lambda 함수 생성
resource "aws_lambda_function" "todo_api" {
  function_name    = "todo-api"
  filename         = var.lambda_zip_path
  source_code_hash = filebase64sha256(var.lambda_zip_path)
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      TODO_TABLE_NAME       = aws_dynamodb_table.todo_table.name
      POWERTOOLS_SERVICE_NAME = "todo-api"
      LOG_LEVEL             = "INFO"
    }
  }

  tags = {
    Name        = "TodoApiLambda"
    Environment = var.environment
    Project     = "TodoApp"
  }
}

# API Gateway REST API 생성
resource "aws_api_gateway_rest_api" "todo_api" {
  name        = "todo-service"
  description = "Todo Service API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "TodoApi"
    Environment = var.environment
    Project     = "TodoApp"
  }
}

# API Gateway 리소스 생성 - /todos
resource "aws_api_gateway_resource" "todos" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_rest_api.todo_api.root_resource_id
  path_part   = "todos"
}

# API Gateway 리소스 생성 - /todos/{id}
resource "aws_api_gateway_resource" "todo" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  parent_id   = aws_api_gateway_resource.todos.id
  path_part   = "{id}"
}

# API Gateway 메서드 생성 - GET /todos
resource "aws_api_gateway_method" "get_todos" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "GET"
  authorization_type = "NONE"
}

# API Gateway 메서드 생성 - POST /todos
resource "aws_api_gateway_method" "post_todos" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "POST"
  authorization_type = "NONE"
}

# API Gateway 메서드 생성 - GET /todos/{id}
resource "aws_api_gateway_method" "get_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todo.id
  http_method   = "GET"
  authorization_type = "NONE"
}

# API Gateway 메서드 생성 - PUT /todos/{id}
resource "aws_api_gateway_method" "put_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todo.id
  http_method   = "PUT"
  authorization_type = "NONE"
}

# API Gateway 메서드 생성 - DELETE /todos/{id}
resource "aws_api_gateway_method" "delete_todo" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todo.id
  http_method   = "DELETE"
  authorization_type = "NONE"
}

# Lambda 통합 생성 - GET /todos
resource "aws_api_gateway_integration" "get_todos_integration" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = aws_api_gateway_method.get_todos.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.todo_api.invoke_arn
}

# Lambda 통합 생성 - POST /todos
resource "aws_api_gateway_integration" "post_todos_integration" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todos.id
  http_method             = aws_api_gateway_method.post_todos.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.todo_api.invoke_arn
}

# Lambda 통합 생성 - GET /todos/{id}
resource "aws_api_gateway_integration" "get_todo_integration" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todo.id
  http_method             = aws_api_gateway_method.get_todo.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.todo_api.invoke_arn
}

# Lambda 통합 생성 - PUT /todos/{id}
resource "aws_api_gateway_integration" "put_todo_integration" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todo.id
  http_method             = aws_api_gateway_method.put_todo.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.todo_api.invoke_arn
}

# Lambda 통합 생성 - DELETE /todos/{id}
resource "aws_api_gateway_integration" "delete_todo_integration" {
  rest_api_id             = aws_api_gateway_rest_api.todo_api.id
  resource_id             = aws_api_gateway_resource.todo.id
  http_method             = aws_api_gateway_method.delete_todo.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.todo_api.invoke_arn
}

# Lambda 함수에 API Gateway 호출 권한 부여
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.todo_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.todo_api.execution_arn}/*/*"
}

# API Gateway 배포
resource "aws_api_gateway_deployment" "todo_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.get_todos_integration,
    aws_api_gateway_integration.post_todos_integration,
    aws_api_gateway_integration.get_todo_integration,
    aws_api_gateway_integration.put_todo_integration,
    aws_api_gateway_integration.delete_todo_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  stage_name  = var.environment

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway CORS 설정
resource "aws_api_gateway_method" "todos_options" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todos.id
  http_method   = "OPTIONS"
  authorization_type = "NONE"
}

resource "aws_api_gateway_method" "todo_options" {
  rest_api_id   = aws_api_gateway_rest_api.todo_api.id
  resource_id   = aws_api_gateway_resource.todo.id
  http_method   = "OPTIONS"
  authorization_type = "NONE"
}

resource "aws_api_gateway_integration" "todos_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.todos_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration" "todo_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todo.id
  http_method = aws_api_gateway_method.todo_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# CORS 메서드 응답 설정
resource "aws_api_gateway_method_response" "todos_options_response" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.todos_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_method_response" "todo_options_response" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todo.id
  http_method = aws_api_gateway_method.todo_options.http_method
  status_code = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# CORS 통합 응답 설정
resource "aws_api_gateway_integration_response" "todos_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todos.id
  http_method = aws_api_gateway_method.todos_options.http_method
  status_code = aws_api_gateway_method_response.todos_options_response.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_api_gateway_integration_response" "todo_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.todo_api.id
  resource_id = aws_api_gateway_resource.todo.id
  http_method = aws_api_gateway_method.todo_options.http_method
  status_code = aws_api_gateway_method_response.todo_options_response.status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,PUT,DELETE,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}
