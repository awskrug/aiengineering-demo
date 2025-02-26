#!/bin/bash

# Lambda 함수 코드 패키징 스크립트

# 임시 디렉토리 생성
mkdir -p lambda_build

# 필요한 파일 복사
cp -r ../backend/lambda/src/* lambda_build/
cp ../backend/lambda/package.json lambda_build/

# 디렉토리 이동
cd lambda_build

# 의존성 설치
npm install --production

# ZIP 파일 생성
zip -r ../lambda_function.zip .

# 임시 디렉토리 정리
cd ..
rm -rf lambda_build

echo "Lambda 함수 패키징 완료: lambda_function.zip"
