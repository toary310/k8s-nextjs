# ベースイメージとして Node.js 20を使用
FROM node:20-alpine AS builder

# 作業ディレクトリを設定
WORKDIR /app

# 依存関係ファイルをコピー
COPY package*.json ./

# 依存関係をインストール
RUN npm ci

# ソースコードをコピー
COPY . .

# アプリケーションをビルド
RUN npm run build

# 本番環境用イメージ
FROM node:20-alpine AS runner

WORKDIR /app

# 本番環境用の依存関係のみをインストール
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production

# ビルド済みのアプリケーションをコピー
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./

# 環境変数を設定
ENV NODE_ENV=production
ENV PORT=3000

# ポートを公開
EXPOSE 3000

# アプリケーションを起動
CMD ["npm", "start"]
