#!/bin/bash

# 테라폼 그래프 생성 스크립트
# 이 스크립트는 테라폼 리소스 의존관계를 시각화하여 PNG 및 SVG 파일로 저장합니다.

echo "테라폼 의존관계 그래프 생성 중..."

# 현재 디렉토리가 테라폼 디렉토리인지 확인
if [ ! -f "main.tf" ]; then
  echo "오류: 테라폼 디렉토리에서 실행해주세요."
  exit 1
fi

# 테라폼 초기화 (필요한 경우)
if [ ! -d ".terraform" ]; then
  echo "테라폼 초기화 중..."
  terraform init -input=false
fi

# 그래프 디렉토리 생성
mkdir -p graphs

# PNG 형식 그래프 생성
echo "PNG 그래프 생성 중..."
terraform graph | dot -Tpng > graphs/terraform_graph.png

# SVG 형식 그래프 생성
echo "SVG 그래프 생성 중..."
terraform graph | dot -Tsvg > graphs/terraform_graph.svg

echo "그래프 생성 완료: graphs/terraform_graph.png, graphs/terraform_graph.svg"
