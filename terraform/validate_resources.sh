#!/bin/bash

# 테라폼 리소스 검증 스크립트
# 이 스크립트는 테라폼으로 생성된 AWS 리소스가 의도대로 생성되었는지 확인합니다.

set -e

echo "🔍 테라폼 리소스 검증 시작..."

# 현재 디렉토리가 테라폼 디렉토리인지 확인
if [ ! -f "main.tf" ]; then
  echo "❌ 오류: 테라폼 디렉토리에서 실행해주세요."
  exit 1
fi

# AWS 프로파일 설정
export AWS_PROFILE=personal

# 테라폼 출력값 가져오기
echo "📋 테라폼 출력값 가져오는 중..."
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name 2>/dev/null || echo "")
LAMBDA_FUNCTION=$(terraform output -raw lambda_function_name 2>/dev/null || echo "")
API_GATEWAY_ID=$(terraform output -raw api_gateway_id 2>/dev/null || echo "")
API_GATEWAY_URL=$(terraform output -raw api_gateway_url 2>/dev/null || echo "")

# 결과 저장 변수
PASSED=0
FAILED=0
TOTAL=0

# 테스트 결과 출력 함수
test_result() {
  local resource=$1
  local result=$2
  local details=$3
  
  TOTAL=$((TOTAL+1))
  
  if [ "$result" = "PASS" ]; then
    echo "✅ $resource: 검증 성공"
    PASSED=$((PASSED+1))
  else
    echo "❌ $resource: 검증 실패 - $details"
    FAILED=$((FAILED+1))
  fi
}

# 1. DynamoDB 테이블 검증
echo -e "\n📊 DynamoDB 테이블 검증 중..."
if [ -z "$DYNAMODB_TABLE" ]; then
  test_result "DynamoDB 테이블" "FAIL" "테라폼 출력값이 없습니다."
else
  TABLE_INFO=$(aws dynamodb describe-table --table-name "$DYNAMODB_TABLE" 2>/dev/null || echo "")
  
  if [ -z "$TABLE_INFO" ]; then
    test_result "DynamoDB 테이블" "FAIL" "테이블이 존재하지 않습니다."
  else
    # 테이블 구조 검증
    PARTITION_KEY=$(echo "$TABLE_INFO" | grep -o '"AttributeName": "id"' || echo "")
    
    if [ -z "$PARTITION_KEY" ]; then
      test_result "DynamoDB 파티션 키" "FAIL" "id 파티션 키가 없습니다."
    else
      test_result "DynamoDB 파티션 키" "PASS" ""
    fi
    
    # 테이블 상태 검증
    TABLE_STATUS=$(echo "$TABLE_INFO" | grep -o '"TableStatus": "ACTIVE"' || echo "")
    
    if [ -z "$TABLE_STATUS" ]; then
      test_result "DynamoDB 테이블 상태" "FAIL" "테이블이 활성화되지 않았습니다."
    else
      test_result "DynamoDB 테이블 상태" "PASS" ""
    fi
  fi
fi

# 2. Lambda 함수 검증
echo -e "\n🧩 Lambda 함수 검증 중..."
if [ -z "$LAMBDA_FUNCTION" ]; then
  test_result "Lambda 함수" "FAIL" "테라폼 출력값이 없습니다."
else
  LAMBDA_INFO=$(aws lambda get-function --function-name "$LAMBDA_FUNCTION" 2>/dev/null || echo "")
  
  if [ -z "$LAMBDA_INFO" ]; then
    test_result "Lambda 함수" "FAIL" "함수가 존재하지 않습니다."
  else
    # 런타임 검증
    RUNTIME=$(echo "$LAMBDA_INFO" | grep -o '"Runtime": "nodejs18.x"' || echo "")
    
    if [ -z "$RUNTIME" ]; then
      test_result "Lambda 런타임" "FAIL" "Node.js 18.x 런타임이 아닙니다."
    else
      test_result "Lambda 런타임" "PASS" ""
    fi
    
    # 환경 변수 검증
    ENV_VARS=$(echo "$LAMBDA_INFO" | grep -o '"Variables": {' || echo "")
    
    if [ -z "$ENV_VARS" ]; then
      test_result "Lambda 환경 변수" "FAIL" "환경 변수가 설정되지 않았습니다."
    else
      test_result "Lambda 환경 변수" "PASS" ""
    fi
    
    # 상태 검증
    LAMBDA_STATE=$(echo "$LAMBDA_INFO" | grep -o '"State": "Active"' || echo "")
    
    if [ -z "$LAMBDA_STATE" ]; then
      test_result "Lambda 상태" "FAIL" "함수가 활성화되지 않았습니다."
    else
      test_result "Lambda 상태" "PASS" ""
    fi
  fi
fi

# 3. API Gateway 검증
echo -e "\n🌐 API Gateway 검증 중..."
if [ -z "$API_GATEWAY_ID" ]; then
  test_result "API Gateway" "FAIL" "테라폼 출력값이 없습니다."
else
  API_INFO=$(aws apigateway get-rest-api --rest-api-id "$API_GATEWAY_ID" 2>/dev/null || echo "")
  
  if [ -z "$API_INFO" ]; then
    test_result "API Gateway" "FAIL" "API Gateway가 존재하지 않습니다."
  else
    # API 이름 검증
    API_NAME=$(echo "$API_INFO" | grep -o '"name": "todo-service"' || echo "")
    
    if [ -z "$API_NAME" ]; then
      test_result "API Gateway 이름" "FAIL" "API 이름이 'todo-service'가 아닙니다."
    else
      test_result "API Gateway 이름" "PASS" ""
    fi
    
    # 리소스 검증
    RESOURCES=$(aws apigateway get-resources --rest-api-id "$API_GATEWAY_ID" 2>/dev/null || echo "")
    ROOT_RESOURCE=$(echo "$RESOURCES" | grep -o '"path": "/"' || echo "")
    
    if [ -z "$ROOT_RESOURCE" ]; then
      test_result "API Gateway 루트 리소스" "FAIL" "루트 리소스가 없습니다."
    else
      test_result "API Gateway 루트 리소스" "PASS" ""
    fi
    
    # 엔드포인트 검증 (API URL이 있는 경우)
    if [ -n "$API_GATEWAY_URL" ]; then
      # OPTIONS 메서드로 CORS 확인 (실제 요청 없이)
      CORS_CHECK=$(curl -s -I -X OPTIONS "$API_GATEWAY_URL" | grep -i "access-control-allow-origin" || echo "")
      
      if [ -z "$CORS_CHECK" ]; then
        test_result "API Gateway CORS" "FAIL" "CORS 헤더가 설정되지 않았습니다."
      else
        test_result "API Gateway CORS" "PASS" ""
      fi
    else
      test_result "API Gateway URL" "FAIL" "API Gateway URL이 없습니다."
    fi
  fi
fi

# 결과 요약
echo -e "\n📝 검증 결과 요약"
echo "총 테스트: $TOTAL"
echo "성공: $PASSED"
echo "실패: $FAILED"

# 결과 파일 생성
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
RESULT_FILE="validation_result_$TIMESTAMP.txt"

{
  echo "테라폼 리소스 검증 결과"
  echo "실행 시간: $(date)"
  echo ""
  echo "총 테스트: $TOTAL"
  echo "성공: $PASSED"
  echo "실패: $FAILED"
  echo ""
  echo "DynamoDB 테이블: $DYNAMODB_TABLE"
  echo "Lambda 함수: $LAMBDA_FUNCTION"
  echo "API Gateway ID: $API_GATEWAY_ID"
  echo "API Gateway URL: $API_GATEWAY_URL"
} > "$RESULT_FILE"

echo "결과가 $RESULT_FILE 파일에 저장되었습니다."

# 종료 코드 설정
if [ $FAILED -gt 0 ]; then
  echo "❌ 일부 리소스가 의도대로 생성되지 않았습니다."
  exit 1
else
  echo "✅ 모든 리소스가 의도대로 생성되었습니다."
  exit 0
fi
