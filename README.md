# SQL アンチパターン検証環境

SQL アンチパターンをローカルで検証するためのサンドボックス環境です。

## 環境構築

### 必要なもの
- Docker
- Docker Compose
- psql クライアント（オプション）

### セットアップ

```bash
# PostgreSQL コンテナを起動
docker-compose up -d

# コンテナが正常に起動していることを確認
docker-compose ps

# データベースに接続
docker-compose exec postgres psql -U postgres -d antipatterns
```

### データベース停止

```bash
docker-compose down

# データも含めて削除する場合
docker-compose down -v
```

### 環境のリセット

```bash
# リセットスクリプトを実行（データベースを完全に初期化）
./reset.sh
```

## ディレクトリ構造

各アンチパターンごとにディレクトリを作成し、それぞれに以下のファイルを配置します：

```
antipattern-name/
├── README.md          # アンチパターンの説明と検証内容
├── schema.sql         # テーブル定義
├── data.sql           # テストデータ
├── antipattern.sql    # アンチパターンの例
├── solution.sql       # 改善案
└── benchmark.sql      # パフォーマンス計測用クエリ
```

## アンチパターン一覧

### 12章: インデックスショットガン (Index Shotgun)
インデックスを過剰に作成することで書き込み性能が低下する問題を検証

### 16章: プアマンズサーチエンジン (Poor Man's Search Engine)
LIKE 検索と PostgreSQL の全文検索機能のパフォーマンス比較

## 使い方

### Makefile を使用した実行（推奨）

```bash
# 使用可能なコマンドを表示
make help

# Docker コンテナを起動
make up

# インデックスショットガンの検証を実行
make 12-index-shotgun
make 12-benchmark
make 12-solution

# プアマンズサーチエンジンの検証を実行
make 16-poor-mans-search
make 16-benchmark
make 16-solution

# 個別のアンチパターンをリセット
make 12-index-shotgun-reset
make 16-poor-mans-search-reset

# データベースに接続
make psql

# 環境を完全にリセット
make reset
```

### 手動実行

各アンチパターンのディレクトリに移動して、以下の手順で検証することも可能です：

```bash
# 例: インデックスショットガンの検証
cd 12-index-shotgun

# スキーマとデータを作成
docker-compose exec -T postgres psql -U postgres -d antipatterns < schema.sql
docker-compose exec -T postgres psql -U postgres -d antipatterns < data.sql

# アンチパターンの実行
docker-compose exec -T postgres psql -U postgres -d antipatterns < antipattern.sql

# パフォーマンス測定
docker-compose exec -T postgres psql -U postgres -d antipatterns < benchmark.sql

# 改善案の実行
docker-compose exec -T postgres psql -U postgres -d antipatterns < solution.sql

# 個別のアンチパターンをリセット
docker-compose exec -T postgres psql -U postgres -d antipatterns < reset.sql
```

### インタラクティブな実行

```bash
# データベースに直接接続して手動実行
docker-compose exec postgres psql -U postgres -d antipatterns

# psql プロンプトで各SQLファイルを実行
\i 12-index-shotgun/schema.sql
\i 12-index-shotgun/data.sql
```

## パフォーマンス計測

PostgreSQL の `EXPLAIN ANALYZE` を使用してクエリのパフォーマンスを計測します：

```sql
EXPLAIN (ANALYZE, BUFFERS, TIMING) 
SELECT * FROM your_table WHERE condition;
```

## トラブルシューティング

### ポートが既に使用されている場合

```bash
# 5432 ポートを使用しているプロセスを確認
docker ps -a | grep 5432

# 既存のコンテナを停止
docker stop <container_name>
docker rm <container_name>
```

### データベースに接続できない場合

```bash
# コンテナのログを確認
docker-compose logs postgres

# コンテナの状態を確認
docker-compose ps

# 環境を完全にリセット
./reset.sh
```