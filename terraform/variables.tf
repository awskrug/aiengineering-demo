variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "배포 환경 (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "dynamodb_table_name" {
  description = "DynamoDB 테이블 이름"
  type        = string
  default     = "TodoTable"
}

variable "lambda_zip_path" {
  description = "Lambda 함수 코드가 포함된 ZIP 파일 경로"
  type        = string
  default     = "lambda_function.zip"
}
