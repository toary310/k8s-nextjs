{{/*
# Helmチャートの基本構成と役割

## ディレクトリ構造の説明
- Chart.yaml: チャートのメタデータを定義（バージョン、説明など）
- values.yaml: デフォルト値を定義するファイル
- templates/: Kubernetesマニフェストのテンプレートを格納
- charts/: 依存チャートを格納（サブチャート）

## templatesディレクトリの主要ファイル
- deployment.yaml: Podのレプリカを管理
- service.yaml: Podへのネットワークアクセスを提供
- ingress.yaml: 外部からのアクセスルールを定義
- serviceaccount.yaml: サービスアカウントの権限を定義
- _helpers.tpl: 共通で使用するテンプレート関数を定義

## Helmの変数参照方法
1. values.yamlの値を参照: .Values.キー名
2. チャートメタデータの参照: .Chart.キー名
3. リリース情報の参照: .Release.キー名

## デプロイ時の動作フロー
1. helm installコマンドの実行
2. values.yamlとコマンドライン引数の値を読み込み
3. テンプレートをレンダリング
4. 生成されたマニフェストをKubernetesに適用

## ベストプラクティス
1. デフォルト値は必ず設定する
2. テンプレート関数は再利用可能に設計
3. 適切なバリデーションを含める
4. セキュリティ設定を慎重に行う
5. リソース制限を適切に設定
*/}}

{{/*
helm-chart.nameテンプレート
アプリケーション名を生成するためのヘルパー関数

引数:
- .Values.nameOverride: カスタム名（オプション）
- .Chart.Name: チャート名（デフォルト値）

動作:
1. .Values.nameOverrideが設定されている場合はその値を使用
2. 未設定の場合は.Chart.Nameを使用
3. 63文字に切り詰め
4. 末尾のハイフンを削除

使用例:
name: {{ include "helm-chart.name" . }}
*/}}
{{- define "helm-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
共通ラベルの定義
すべてのリソースに適用する共通ラベルを生成するヘルパー関数

使用例:
{{- include "helm-chart.labels" . | nindent 4 }}
*/}}
{{- define "helm-chart.labels" -}}
app: {{ .Values.application.name }}
environment: {{ .Values.application.environment }}
{{- end }}
