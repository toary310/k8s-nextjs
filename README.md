# Next.js on Kubernetes

このプロジェクトは、Next.js 15.1で構築されたWebアプリケーションをKubernetes環境で実行するためのリファレンス実装です。開発環境での実行と、ローカルKubernetes環境（Docker Desktop KubernetesまたはMinikube）でのデプロイに対応しています。

## システム要件と前提条件

### 必要なソフトウェア
- Node.js v20.x以上
- npm v10.x以上
- Docker
- Kubernetes環境（Docker Desktop KubernetesまたはMinikube）
- kubectl コマンドライン
- Helm v3.x以上

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

## 実行方法2: Docker Desktop Kubernetes環境

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

## 実行方法3: Minikube環境

Minikubeを使用して、より軽量なローカルKubernetes環境でアプリケーションを実行する方法です。

### 1. Minikube環境の準備
```bash
# Minikubeの起動
minikube start

# Minikubeの状態確認
minikube status

# Ingressアドオンの有効化（初回のみ）
minikube addons enable ingress

# Minikubeの状態を確認
kubectl cluster-info
```

### 2. アプリケーションのデプロイ
```bash
# Dockerイメージをビルド
docker build -t nextjs-app:latest .

# Minikubeにイメージをロード
minikube image load nextjs-app:latest

# Helmチャートのインストール
helm install nextjs-app ./helm-chart
```

### 3. デプロイ状態の確認
```bash
# Podの状態確認
kubectl get pods -l app=nextjs-app

# 各リソースの確認
kubectl get deployment,service,ingress -l app=nextjs-app
```

### 4. アプリケーションへのアクセス方法（2つの選択肢）

#### 方法A: Port-Forwardを使用
```bash
# Serviceへのポートフォワード設定
kubectl port-forward svc/nextjs-app 3000:3000
```
- ブラウザでアクセス: http://localhost:3000

#### 方法B: Minikube Serviceを使用
```bash
# MinikubeのService URLを取得して自動的にアクセス
minikube service nextjs-app --url
```
- 表示されたURLにブラウザでアクセス

#### 方法C: Ingressを使用（hostsファイルの設定が必要）
```bash
# /etc/hosts に以下を追加
127.0.0.1 nextjs-app.local

# Minikubeトンネルを実行
minikube tunnel
```
- ブラウザでアクセス: http://nextjs-app.local

### 5. アプリケーションの停止
```bash
# Helmリリースの削除
helm uninstall nextjs-app

# Minikubeトンネルを停止（使用している場合）
# Ctrl+C でプロセスを終了

# 必要に応じてMinikubeを停止
minikube stop
```

## Helm構成の解説

このプロジェクトは、Helmを使用してKubernetesリソースを管理しています。

### Helmディレクトリ構造
```
helm-chart/
├── .helmignore        # Helmが無視するファイルパターン
├── Chart.yaml         # チャートのメタデータ
├── values.yaml        # デフォルト設定値
└── templates/         # Kubernetesマニフェストテンプレート
    ├── _helpers.tpl       # 共通ヘルパー関数
    ├── deployment.yaml    # アプリケーションのデプロイメント
    ├── service.yaml       # サービス定義
    ├── ingress.yaml       # Ingress設定
    └── NOTES.txt          # インストール後の説明文
```

### 主要設定パラメータ（values.yaml）

- `application.name`: アプリケーション名
- `application.environment`: 環境名（development, staging, production）
- `image.repository`: Dockerイメージのリポジトリ
- `image.tag`: イメージのタグ
- `deployment.replicas`: レプリカ数
- `deployment.resources`: CPUとメモリのリソース設定
- `service.type`: Serviceタイプとポートマッピング
- `ingress.enabled`: Ingressの有効化フラグ
- `ingress.hosts`: ホスト名とパスの設定

### Helmコマンド集

```bash
# インストール
helm install nextjs-app ./helm-chart

# 更新
helm upgrade nextjs-app ./helm-chart

# 値の上書き
helm upgrade --install nextjs-app ./helm-chart --set deployment.replicas=2

# カスタム値ファイルの使用
helm upgrade --install nextjs-app ./helm-chart -f custom-values.yaml

# リリース情報の確認
helm list
helm status nextjs-app

# マニフェストの生成（適用せずに確認）
helm template nextjs-app ./helm-chart > generated-manifests.yaml

# アンインストール
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

### Kubernetes環境での問題

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

#### 3. Serviceのエンドポイントが空になる
```bash
# Serviceの詳細確認
kubectl describe service nextjs-app

# Podのラベルを確認
kubectl get pods --show-labels
```

問題: セレクター（app=nextjs-app,environment=development）とPodのラベルが一致していない
解決策: Helmチャートを修正するか、一時的にServiceのセレクターを変更
```bash
kubectl patch service nextjs-app -p '{"spec":{"selector":{"app":"nextjs-app"}}}'
```

#### 4. Ingressにアクセスできない
```bash
# Ingressコントローラーの状態確認（Docker Desktop）
kubectl get pods -n ingress-nginx

# Ingressコントローラーの状態確認（Minikube）
minikube addons list | grep ingress

# Ingressリソースの確認
kubectl get ingress --all-namespaces

# hostsファイルの確認
cat /etc/hosts | grep nextjs-app.local
```

#### 5. 名前空間間のリソース競合

問題: `host "nextjs-app.local" and path "/" is already defined in ingress your-namespace/nextjs-app`
解決策: 競合しているIngressリソースを削除
```bash
kubectl delete ingress nextjs-app -n your-namespace
```

## リソース制限

ローカルKubernetes環境での設定:
- CPU: request 100m, limit 500m
- メモリ: request 128Mi, limit 512Mi

## Kubernetes学習リソース

このプロジェクトで学べる要素:

1. **コンテナ化**: Next.jsアプリケーションのマルチステージDockerビルド
2. **Kubernetes基本リソース**: Deployment, Service, Pod, Ingressの連携
3. **Helmによるパッケージング**: テンプレート化、値の管理、リリース
4. **ラベルとセレクター**: リソース間の関連付けメカニズム
5. **ネットワーキング**: クラスター内通信と外部公開の方法
6. **環境変数**: アプリケーション設定の管理

## サポートとフィードバック

問題が解決しない場合は、以下の情報を含めてIssueを作成してください：
- 発生している問題の詳細な説明
- 実行環境（Docker Desktop / Minikube）とモード
- エラーメッセージのスクリーンショットまたはログ
- 実行したコマンドと結果
