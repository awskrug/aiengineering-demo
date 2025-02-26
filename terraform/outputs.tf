output "api_gateway_url" {
  description = "API Gateway 엔드포인트 URL"
  value       = "${aws_api_gateway_deployment.todo_api_deployment.invoke_url}"
}

output "dynamodb_table_name" {
  description = "생성된 DynamoDB 테이블 이름"
  value       = aws_dynamodb_table.todo_table.name
}

output "lambda_function_name" {
  description = "생성된 Lambda 함수 이름"
  value       = aws_lambda_function.todo_api.function_name
}

output "api_gateway_id" {
  description = "생성된 API Gateway ID"
  value       = aws_api_gateway_rest_api.todo_api.id
}

output "api_gateway_stage" {
  description = "API Gateway 스테이지 이름"
  value       = var.environment
}
