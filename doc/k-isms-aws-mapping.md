# K-ISMS 규정과 AWS Config 규칙 매핑

## 개요
이 문서는 한국 정보보호 관리체계(K-ISMS) 인증 요구사항과 AWS Config 규칙 간의 매핑을 제공합니다. AWS Control Tower를 통해 이러한 규칙을 적용하여 K-ISMS 규정 준수를 지원할 수 있습니다.

## K-ISMS 통제 영역과 AWS Config 규칙 매핑

### 1. 관리체계 수립 및 운영

#### 1.1 정보보호 정책 수립
| K-ISMS 통제항목 | AWS Config 규칙 | 설명 |
|--------------|-----------------|------|
| 정보보호 정책 수립 | account-part-of-organizations | 계정이 AWS Organizations에 속해 있는지 확인하여 중앙 집중식 정책 관리 지원 |
| | cloudtrail-security-trail-enabled | 보안 관련 이벤트를 기록하는 CloudTrail이 활성화되어 있는지 확인 |

#### 1.2 정보보호 조직 구성 및 운영
| K-ISMS 통제항목 | AWS Config 규칙 | 설명 |
|--------------|-----------------|------|
| 정보보호 조직 구성 | iam-group-has-users-check | IAM 그룹에 사용자가 포함되어 있는지 확인하여 조직적 접근 제어 지원 |
| | iam-policy-no-statements-with-admin-access | 관리자 권한이 있는 IAM 정책 제한 |

### 2. 보호대책 구현

#### 2.1 인적 보안
| K-ISMS 통제항목 | AWS Config 규칙 | 설명 |
|--------------|-----------------|------|
| 접근 권한 관리 | access-keys-rotated | 접근 키가 정기적으로 교체되는지 확인 |
| | iam-user-unused-credentials-check | 미사용 자격 증명 확인 |
| | iam-password-policy | 안전한 암호 정책 적용 여부 확인 |

#### 2.2 접근 통제
| K-ISMS 통제항목 | AWS Config 규칙 | 설명 |
|--------------|-----------------|------|
| 사용자 인증 | iam-user-mfa-enabled | 사용자 계정에 MFA가 활성화되어 있는지 확인 |
| | mfa-enabled-for-iam-console-access | IAM 콘솔 접근에 MFA가 활성화되어 있는지 확인 |
| | root-account-mfa-enabled | 루트 계정에 MFA가 활성화되어 있는지 확인 |
| 접근 권한 | iam-root-access-key-check | 루트 계정의 접근 키 사용 제한 확인 |
| | iam-user-no-policies-check | 사용자에게 직접 정책이 연결되어 있지 않은지 확인 |
| 네트워크 접근 | restricted-ssh | SSH 접근이 제한되어 있는지 확인 |
| | restricted-common-ports | 일반적인 포트에 대한 접근이 제한되어 있는지 확인 |
| | vpc-default-security-group-closed | 기본 보안 그룹이 닫혀 있는지 확인 |
| | vpc-sg-open-only-to-authorized-ports | 보안 그룹이 승인된 포트에만 열려 있는지 확인 |

#### 2.3 암호화
| K-ISMS 통제항목 | AWS Config 규칙 | 설명 |
|--------------|-----------------|------|
| 암호화 적용 | alb-http-to-https-redirection-check | HTTP에서 HTTPS로의 리디렉션 확인 |
| | api-gw-cache-enabled-and-encrypted | API Gateway 캐시가 활성화되고 암호화되어 있는지 확인 |
| | cloudwatch-log-group-encrypted | CloudWatch 로그 그룹이 암호화되어 있는지 확인 |
| | cloud-trail-encryption-enabled | CloudTrail이 암호화되어 있는지 확인 |
| | dynamodb-table-encrypted-kms | DynamoDB 테이블이 KMS로 암호화되어 있는지 확인 |
| | ec2-ebs-encryption-by-default | EBS 볼륨이 기본적으로 암호화되어 있는지 확인 |
| | efs-encrypted-check | EFS가 암호화되어 있는지 확인 |
| | elb-acm-certificate-required | ELB에 ACM 인증서가 필요한지 확인 |
| | elb-tls-https-listeners-only | ELB 리스너가 TLS/HTTPS만 사용하는지 확인 |
| | encrypted-volumes | 볼륨이 암호화되어 있는지 확인 |
| | rds-storage-encrypted | RDS 스토리지가 암호화되어 있는지 확인 |
| | s3-bucket-server-side-encryption-enabled | S3 버킷에 서버 측 암호화가 활성화되어 있는지 확인 |
| | s3-bucket-ssl-requests-only | S3 버킷이 SSL 요청만 허용하는지 확인 |

#### 2.4 물리적 보안
| K-ISMS 통제항목 | AWS Config 규칙 | 설명 |
|--------------|-----------------|------|
| 물리적 접근 통제 | ec2-instance-no-public-ip | EC2 인스턴스에 공용 IP가 없는지 확인 |
| | lambda-function-public-access-prohibited | Lambda 함수에 공용 접근이 금지되어 있는지 확인 |
| | rds-instance-public-access-check | RDS 인스턴스에 공용 접근이 없는지 확인 |
| | redshift-cluster-public-access-check | Redshift 클러스터에 공용 접근이 없는지 확인 |

#### 2.5 운영 보안
| K-ISMS 통제항목 | AWS Config 규칙 | 설명 |
|--------------|-----------------|------|
| 로깅 및 모니터링 | api-gw-execution-logging-enabled | API Gateway 실행 로깅이 활성화되어 있는지 확인 |
| | cloudtrail-s3-dataevents-enabled | S3 데이터 이벤트에 대한 CloudTrail이 활성화되어 있는지 확인 |
| | cloud-trail-cloud-watch-logs-enabled | CloudTrail에서 CloudWatch 로그가 활성화되어 있는지 확인 |
| | cloudtrail-enabled | CloudTrail이 활성화되어 있는지 확인 |
| | cw-loggroup-retention-period-check | CloudWatch 로그 그룹 보존 기간 확인 |
| | elb-logging-enabled | ELB 로깅이 활성화되어 있는지 확인 |
| | multi-region-cloudtrail-enabled | 다중 리전 CloudTrail이 활성화되어 있는지 확인 |
| | rds-logging-enabled | RDS 로깅이 활성화되어 있는지 확인 |
| | s3-bucket-logging-enabled | S3 버킷 로깅이 활성화되어 있는지 확인 |
| | vpc-flow-logs-enabled | VPC 흐름 로그가 활성화되어 있는지 확인 |
| 취약점 관리 | ec2-managedinstance-association-compliance-status-check | EC2 관리형 인스턴스 연결 규정 준수 상태 확인 |
| | ec2-managedinstance-patch-compliance-status-check | EC2 관리형 인스턴스 패치 규정 준수 상태 확인 |
| | guardduty-non-archived-findings | GuardDuty에서 보관되지 않은 결과 확인 |
| 백업 및 복구 | db-instance-backup-enabled | DB 인스턴스 백업이 활성화되어 있는지 확인 |
| | dynamodb-in-backup-plan | DynamoDB가 백업 계획에 포함되어 있는지 확인 |
| | ebs-in-backup-plan | EBS가 백업 계획에 포함되어 있는지 확인 |
| | efs-in-backup-plan | EFS가 백업 계획에 포함되어 있는지 확인 |
| | rds-in-backup-plan | RDS가 백업 계획에 포함되어 있는지 확인 |
| | s3-bucket-versioning-enabled | S3 버킷 버전 관리가 활성화되어 있는지 확인 |

### 3. 위험 관리

#### 3.1 위험 평가
| K-ISMS 통제항목 | AWS Config 규칙 | 설명 |
|--------------|-----------------|------|
| 위험 평가 | guardduty-enabled-centralized | GuardDuty가 중앙 집중식으로 활성화되어 있는지 확인 |
| | securityhub-enabled | Security Hub가 활성화되어 있는지 확인 |

#### 3.2 모니터링 및 대응
| K-ISMS 통제항목 | AWS Config 규칙 | 설명 |
|--------------|-----------------|------|
| 모니터링 | cloudwatch-alarm-action-check | CloudWatch 경보 작업 확인 |
| | ec2-instance-detailed-monitoring-enabled | EC2 인스턴스 세부 모니터링이 활성화되어 있는지 확인 |
| | rds-enhanced-monitoring-enabled | RDS 향상된 모니터링이 활성화되어 있는지 확인 |

## AWS Control Tower를 통한 구현 방법

AWS Control Tower는 다중 계정 환경에서 보안 및 규정 준수를 관리하는 서비스입니다. K-ISMS 규정 준수를 위해 다음과 같은 방법으로 AWS Control Tower를 구성할 수 있습니다:

1. **AWS Control Tower 설정**:
   - AWS Control Tower 랜딩 존 설정
   - 조직 단위(OU) 구성
   - 계정 프로비저닝 자동화

2. **AWS Config 규칙 적용**:
   - AWS Control Tower의 가드레일 설정
   - 사용자 지정 가드레일 추가
   - K-ISMS 관련 AWS Config 규칙 적용

3. **모니터링 및 보고**:
   - AWS Control Tower 대시보드 활용
   - AWS Security Hub 통합
   - 규정 준수 보고서 생성

## 참고 자료

- [AWS Config K-ISMS 운영 모범 사례](https://docs.aws.amazon.com/ko_kr/config/latest/developerguide/operational-best-practices-for-k-isms.html)
- [AWS Control Tower 설명서](https://docs.aws.amazon.com/controltower/)
- [ISMS-P를 위한 AWS Config 규정 준수 팩 사용하기](https://aws.amazon.com/ko/blogs/korea/aws-conformance-pack-for-k-isms-p-compliance/)
