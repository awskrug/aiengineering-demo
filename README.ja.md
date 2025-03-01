# 🚀 AWS サーバーレス TODO アプリケーション

[![License: CC BY-SA 4.0 KR](https://img.shields.io/badge/License-CC%20BY--SA%204.0%20KR-lightgrey.svg)](https://creativecommons.org/licenses/by-sa/4.0/deed.ko)
[![GitHub stars](https://img.shields.io/github/stars/awskrug/aiengineering-demo)](https://github.com/awskrug/aiengineering-demo/stargazers)
[![デプロイ状態](https://github.com/awskrug/aiengineering-demo/actions/workflows/frontend-deploy.yml/badge.svg)](https://todo.awskrug.dev)

AWS サーバーレスアーキテクチャを活用した現代的な TODO アプリケーションです。このプロジェクトは [2025年1月22日に開催された AWS Korea User Groupの AI エンジニアリングミートアップ](https://www.meetup.com/awskrug/events/305372486/?slug=awskrug&eventId=305372486)での発表内容の一部として、ライブコーディングを通じて制作されました。

🔗 [デモアプリケーション](https://awskrug.github.io/aiengineering-demo/) - 時間の関係上、フロントエンドのみデプロイしました

## 📚 プロジェクトドキュメント

- プレゼンテーション資料
  - [CDDが来る](https://bit.ly/3DRyxNA)
  - [AIを使用したインフラ自動販売機](https://bit.ly/3CY8ogd)

- [設計ドキュメント](doc/ja/design.md) - プロジェクトアーキテクチャと技術スタック
- [タスクリスト](doc/ja/todo.md) - 開発進捗状況とTODOリスト
- [デモシナリオ](doc/ja/demo_scenario.md) - AIエンジニアリングデモの進行プロセス
- [セキュリティコンプライアンス](doc/ja/compliance.md) - K-ISMS要件マッピング
- [K-ISMS AWSマッピング](doc/ja/k-isms-aws-mapping.md) - K-ISMS規制とAWS Config規則のマッピング
- [ピアレビュー](doc/ja/peer_review.md) - 開発者分析と改善提案
- [Terraformテンプレート](terraform/README.ja.md) - AWSインフラTerraformテンプレート

## ✨ 主な機能

- 📝 TODO項目の作成、照会、修正、削除
- 🔐 ユーザー認証（会員登録/ログイン）
- 📱 レスポンシブデザイン
- 🌐 サーバーレスアーキテクチャ

## 🛠️ 技術スタック

### フロントエンド
- React.js
- TypeScript
- Material-UI
- React Query
- React Router

### バックエンド
- AWS CDK
- AWS Lambda
- Amazon DynamoDB
- Amazon Cognito
- Amazon API Gateway

## 🏗 システムアーキテクチャ

```mermaid
graph TB
    subgraph Frontend["フロントエンド (React)"]
        UI[ユーザーインターフェース]
        RC[Reactコンポーネント]
        RQ[React Query]
        UI --> RC
        RC --> RQ
    end

    subgraph APIGateway["API Gateway"]
        API[REST API]
    end

    subgraph Lambda["Lambda関数"]
        Handler[APIハンドラー]
        Service[Todoサービス]
        Handler --> Service
    end

    subgraph DynamoDB["DynamoDB"]
        Table[Todoテーブル]
    end

    RQ --> API
    API --> Handler
    Service --> Table

    style Frontend fill:#f9f,stroke:#333,stroke-width:2px
    style APIGateway fill:#bbf,stroke:#333,stroke-width:2px
    style Lambda fill:#bfb,stroke:#333,stroke-width:2px
    style DynamoDB fill:#fbb,stroke:#333,stroke-width:2px
```

### システム相互作用

```mermaid
sequenceDiagram
    actor User
    participant Frontend
    participant Cognito
    participant API as API Gateway
    participant Lambda
    participant DynamoDB

    %% 認証プロセス
    User->>Frontend: 1. ログイン試行
    Frontend->>Cognito: 2. 認証リクエスト
    Cognito-->>Frontend: 3. JWTトークン返却
    
    %% TODO操作プロセス
    User->>Frontend: 4. TODO作成
    Frontend->>API: 5. POST /todos (with JWT)
    API->>Lambda: 6. リクエスト転送
    Lambda->>DynamoDB: 7. TODO項目保存
    DynamoDB-->>Lambda: 8. 保存完了
    Lambda-->>API: 9. レスポンス返却
    API-->>Frontend: 10. 作成されたTODO返却
    Frontend-->>User: 11. UI更新

    %% TODO照会プロセス
    User->>Frontend: 12. TODOリストリクエスト
    Frontend->>API: 13. GET /todos (with JWT)
    API->>Lambda: 14. リクエスト転送
    Lambda->>DynamoDB: 15. TODOリスト照会
    DynamoDB-->>Lambda: 16. TODOリスト返却
    Lambda-->>API: 17. レスポンス返却
    API-->>Frontend: 18. TODOリスト返却
    Frontend-->>User: 19. リスト表示
```

## 🚀 はじめに

### 前提条件

- Node.js v18以上
- AWS CLI設定済み
- AWS CDK CLIインストール済み

### インストール方法

1. リポジトリのクローン
```bash
git clone https://github.com/awskrug/aiengineering-demo.git
cd aiengineering-demo
```

2. バックエンドのデプロイ
```bash
cd backend
npm install
npm run cdk deploy
```

3. フロントエンドの実行
```bash
cd frontend
npm install
npm start
```

## 🌳 ブランチ管理

このプロジェクトは[GitHub Flow](https://guides.github.com/introduction/flow/)ブランチ戦略に従います。

### ブランチ戦略ダイアグラム

```mermaid
gitGraph
    commit
    branch feature/auth
    checkout feature/auth
    commit id: "ユーザー認証実装"
    checkout main
    merge feature/auth
    branch feature/todo-crud
    checkout feature/todo-crud
    commit id: "TODO CRUD実装"
    checkout main
    merge feature/todo-crud
    branch bugfix/auth-error
    checkout bugfix/auth-error
    commit id: "認証エラー修正"
    checkout main
    merge bugfix/auth-error
```

### 主要ブランチ
- `main`: 製品の安定バージョンを管理する基本ブランチ
- `feature/*`: 新機能開発用ブランチ
- `bugfix/*`: バグ修正用ブランチ

### ブランチ命名規則
- 機能開発: `feature/login`, `feature/todo-list`
- バグ修正: `bugfix/auth-error`, `bugfix/api-timeout`

### 作業プロセス
1. 新しい作業開始
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/new-feature
   ```

2. 作業中の定期的なコミット
   ```bash
   git add .
   git commit -m "feat: 新機能実装"
   git push origin feature/new-feature
   ```

## 📄 ライセンス

このプロジェクトは[クリエイティブ・コモンズ 表示 - 継承 4.0 国際 ライセンス](https://creativecommons.org/licenses/by-sa/4.0/deed.ja)の下で提供されています。

## 🤝 貢献

プロジェクトへの貢献に興味がある方は、以下の手順に従ってください：

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'feat: 素晴らしい機能を追加'`)
4. ブランチをプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを開く

## 👥 メンテナ

- [AWSKRUG AI Engineering](https://github.com/awskrug)

## 🙏 謝辞

- AWS Korea User Group コミュニティメンバー
- このプロジェクトに貢献してくださった全ての方々

---

*このREADMEは[韓国語](README.md)でも利用可能です。*
