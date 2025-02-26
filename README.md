# Next.js アプリケーション

このアプリケーションは、Next.js 15.1で構築されたWebアプリケーションです。通常の開発サーバーでの実行と、ローカルKubernetes環境での実行の両方に対応しています。

## システム要件と前提条件

### 必要なソフトウェア
- Node.js v20.x以上
- npm v10.x以上
- Docker Desktop（Kubernetes有効化）
- kubectl コマンドライン
- Helm v3.x以上
- VSCode（推奨）

## 実行方法1: 通常の開発サーバー

Next.jsの開発サーバーを直接実行する方法です。高速な開発サイクルとホットリロードが利用可能です。

### 1. 依存関係のインストール
```bash
npm install
```

### 2. 開発サーバーの起動
```bash
npm run dev
```

#### 開発サーバーのオプション
- `--port`: ポート番号の変更（例：`npm run dev -- --port 3001`）
- `--hostname`: ホスト名の設定（例：`npm run dev -- --hostname 0.0.0.0`）

### 3. アプリケーションへのアクセス
- URL: http://localhost:3000
- ヘルスチェック: http://localhost:3000/api/health

### 4. 開発サーバーの停止
```bash
# Ctrl+C でプロセスを終了
```

## 実行方法2: ローカルKubernetes環境

Docker DesktopのKubernetesを使用してローカルで実行する方法です。本番環境に近い形でアプリケーションをテストできます。

### 1. Kubernetes環境の準備
```bash
# Docker Desktopで Kubernetes を有効化

# Kubernetesの状態確認
kubectl config get-contexts
kubectl cluster-info

# nginx-ingressのインストール（初回のみ）
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
```

### 2. hostsファイルの設定
```bash
# /etc/hosts に以下を追加
127.0.0.1 nextjs-app.local
```

### 3. アプリケーションのデプロイ
```bash
# Dockerイメージのビルド
docker build -t nextjs-app:latest .

# Helmチャートのインストール
helm install nextjs-app ./helm-chart
```

### 4. デプロイ状態の確認
```bash
# Podの状態確認
kubectl get pods -l app=nextjs-app

# 各リソースの確認
kubectl get deployment,service,ingress -l app=nextjs-app
```

### 5. アプリケーションへのアクセス
- URL: http://nextjs-app.local
- ヘルスチェック: http://nextjs-app.local/api/health

### 6. アプリケーションの停止
```bash
# Helmリリースの削除
helm uninstall nextjs-app
```

## 開発時のトラブルシューティング

### 通常の開発サーバーの問題

#### 1. アプリケーションが起動しない
- Node.jsのバージョンを確認
```bash
node --version  # v20.x以上であることを確認
```
- 依存関係の再インストール
```bash
rm -rf node_modules
npm install
```

#### 2. ポートの競合
```bash
# ポート3000を使用しているプロセスの確認
lsof -i :3000
# プロセスの終了
kill -9 <PID>
```

### ローカルKubernetes環境の問題

#### 1. イメージのビルドに失敗する
```bash
# Dockerデーモンの状態確認
docker info

# キャッシュのクリーン
docker builder prune
```

#### 2. Podが起動しない
```bash
# Podの詳細確認
kubectl describe pod -l app=nextjs-app

# ログの確認
kubectl logs -l app=nextjs-app
```

#### 3. Ingressにアクセスできない
```bash
# Ingressコントローラーの状態確認
kubectl get pods -n ingress-nginx

# hostsファイルの確認
cat /etc/hosts | grep nextjs-app.local
```

## リソース制限

ローカルKubernetes環境での設定:
- CPU: request 100m, limit 500m
- メモリ: request 128Mi, limit 512Mi

## サポートとフィードバック

問題が解決しない場合は、以下の情報を含めてIssueを作成してください：
- 発生している問題の詳細な説明
- 実行環境とモード（開発サーバー / ローカルKubernetes）
- エラーメッセージのスクリーンショットまたはログ
- 実行したコマンドと結果
