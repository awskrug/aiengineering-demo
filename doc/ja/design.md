# TODOアプリケーション設計ドキュメント

## 1. 概要
このドキュメントはサーバーレスアーキテクチャをベースにしたTODOウェブアプリケーションの設計内容を記載しています。

## 2. システムアーキテクチャ

### 2.1 フロントエンド
- **技術スタック**
  - React.js
  - TypeScript
  - Material-UI (デザインシステム)
  - GitHub Pages (ホスティング)
  - Vite (ビルドツール)
  - TanStack Query (状態管理)

### 2.2 フロントエンド実装詳細

#### 技術スタック
- React + TypeScript
- Vite (ビルドツール)
- Material-UI (UIコンポーネント)
- TanStack Query (状態管理)

#### ディレクトリ構造
```
frontend/
├── src/
│   ├── components/     # 再利用可能なコンポーネント
│   ├── pages/         # ページコンポーネント
│   ├── services/      # APIサービス (モックアップ含む)
│   ├── hooks/         # カスタムフック
│   └── types/         # TypeScript型定義
```

#### コンポーネント構造
- `TodoPage`: メインページコンポーネント
  - `AddTodoForm`: TODO項目追加フォーム
  - `TodoList`: TODOリストコンテナ
    - `TodoItem`: 個別TODO項目

#### データフロー
1. `useTodos`フックでReact Queryを使用してTODOデータ管理
2. モックアップサービス (`mockTodoService`)でAPIコールをシミュレーション
3. コンポーネントからフックを通じてデータアクセスおよび修正

#### APIインターフェース
```typescript
interface TodoService {
  getTodos(): Promise<Todo[]>;
  getTodo(id: string): Promise<Todo>;
  createTodo(input: CreateTodoInput): Promise<Todo>;
  updateTodo(input: UpdateTodoInput): Promise<Todo>;
  deleteTodo(id: string): Promise<void>;
}
```

### 2.2 バックエンド
- **技術スタック**
  - AWS CDK (TypeScript)
  - AWS Lambda
  - Amazon DynamoDB
  - Amazon API Gateway
  - Amazon Cognito (認証)

## 3. 主な機能
- 会員登録
- ログイン/ログアウト
- パスワードリセット
- TODO項目作成
- TODO項目照会 (全リスト)
- TODO項目修正
- TODO項目削除
- TODO項目完了状態トグル

## 4. データモデル

### 4.1 DynamoDBテーブル構造
```
Table: TodoItems
- id: string (パーティションキー)
- userId: string (ソートキー)
- title: string
- description: string (オプション)
- completed: boolean
- createdAt: number (Unixタイムスタンプ)
- updatedAt: number (Unixタイムスタンプ)
```

### 4.2 Cognitoユーザー属性
```
- email (必須)
- name
- phone_number (オプション)
```

## 5. API設計

### 5.1 認証関連API
- `POST /auth/signup` - 会員登録
- `POST /auth/login` - ログイン
- `POST /auth/logout` - ログアウト
- `POST /auth/forgot-password` - パスワードリセットリクエスト
- `POST /auth/reset-password` - パスワードリセット

### 5.2 REST APIエンドポイント
- `GET /todos` - すべてのTODO項目照会
- `POST /todos` - 新しいTODO項目作成
- `PUT /todos/{id}` - 特定のTODO項目修正
- `DELETE /todos/{id}` - 特定のTODO項目削除

## 6. セキュリティ

### 6.1 認証/認可
- Cognito User Poolを通じたユーザー認証
  - メールベースの会員登録
  - メール認証必須
  - パスワードポリシー適用 (最小8文字、特殊文字、大小文字、数字を含む)
- JWTトークンベースの認証
  - Access Token、Refresh Tokenの活用
  - API GatewayでCognito Authorizerを統合
- CORS設定
- APIリクエスト制限 (Rate Limiting)

### 6.2 フロントエンドセキュリティ
- トークン管理
  - Access Tokenはメモリに保存
  - Refresh TokenはHttpOnlyクッキーで管理
- XSS防止
- CSRF防止

## 7. インフラストラクチャ

### 7.1 AWSリソース (CDKで構成)
- Lambda関数
  - createTodo
  - getTodos
  - updateTodo
  - deleteTodo
- DynamoDBテーブル
- API Gateway (REST API)
- Cognito User Pool

### 7.2 CI/CD
- GitHub Actionsを通じた自動デプロイ
  - フロントエンド: GitHub Pagesデプロイ
  - バックエンド: AWS CDKデプロイ

## 8. モニタリングとロギング
- CloudWatch Logsを通じたLambda関数ロギング
- CloudWatch Metricsを通じたAPIモニタリング

## 9. 拡張検討事項
- TODO項目カテゴリ化
- 締切日設定
- 優先順位指定
- 共有機能

## 10. CI/CDパイプライン

### フロントエンドデプロイ
- GitHub Actionsを使用した自動デプロイ
- GitHub Pagesを通じた静的ウェブホスティング
- フロントエンドコード変更時の自動ビルドおよびデプロイ
- 環境変数を通じたAPIエンドポイント管理

### デプロイプロセス
1. frontendディレクトリ変更検知
2. Node.js環境設定
3. 依存関係インストール
4. プロダクションビルド
5. GitHub Pagesデプロイ

## 11. セキュリティおよび規制遵守

### 11.1 K-ISMS規制遵守
- [K-ISMS AWSマッピング](k-isms-aws-mapping.md)ドキュメントに従ったセキュリティ統制実装
- AWS Config規則を活用した継続的な規制遵守モニタリング
- AWS Control Towerを通じた中央集中型セキュリティ管理

### 11.2 AWS Control Tower構成
- 組織単位(OU)設計および構成
- ガードレール設定
- アカウントプロビジョニング自動化
- コンプライアンスダッシュボード構築

### 11.3 セキュリティモニタリングと監査
- AWS Security Hub統合
- コンプライアンスレポート自動化
- セキュリティイベント通知構成
- 定期的なセキュリティ評価プロセス

## 12. Terraformインフラ設計

### 12.1 概要

AWS CDKからTerraformへマイグレーションし、インフラをコードで管理するIaC(Infrastructure as Code)アプローチを実装しました。Terraformはマルチクラウド環境をサポートし、宣言的構成を通じてインフラを管理できるツールです。

### 12.2 Terraform構成要素

#### 12.2.1 リソース構成

- **DynamoDBテーブル**: TODO項目を保存するNoSQLデータベース
  - パーティションキー: `id` (文字列)
  - 読み取り/書き込み容量: オンデマンドモード
  - 自動スケーリング設定

- **Lambda関数**: APIリクエストを処理するサーバーレス関数
  - ランタイム: Node.js 18.x
  - メモリ: 512MB
  - タイムアウト: 10秒
  - 環境変数: テーブル名、ログレベルなど

- **API Gateway**: REST APIエンドポイント提供
  - エンドポイント: GET, POST, PUT, DELETE
  - CORS設定
  - APIキー管理

- **IAMロールとポリシー**: 最小権限原則適用
  - Lambda実行ロール
  - DynamoDBアクセスポリシー

#### 12.2.2 ファイル構造

```
terraform/
├── main.tf           # 主要リソース定義
├── variables.tf      # 変数定義
├── outputs.tf        # 出力変数
├── package_lambda.sh # Lambdaパッケージングスクリプト
└── README.md         # ドキュメント
```

### 12.3 デプロイワークフロー

1. Lambda関数コードパッケージング
2. Terraform初期化 (`terraform init`)
3. デプロイ計画レビュー (`terraform plan`)
4. インフラデプロイ (`terraform apply`)
5. 出力値確認 (API Gateway URLなど)

### 12.4 セキュリティ考慮事項

- IAMロールに最小権限適用
- API Gatewayに適切な認証および認可設定
- 機密情報はAWS Secrets ManagerまたはParameter Store使用
- すべてのデータ転送および保存時に暗号化適用

### 12.5 拡張性と保守性

- モジュール化されたTerraformコードで再利用性向上
- 環境別変数ファイル分離 (dev, staging, prod)
- 状態ファイルリモート保存 (S3 + DynamoDB)
- バージョン管理および変更履歴追跡

### 12.6 今後の改善事項

- Terraformモジュール化改善
- マルチリージョンデプロイサポート
- 災害復旧戦略実装
- CI/CDパイプライン統合
