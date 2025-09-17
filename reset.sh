#!/bin/bash

# SQL アンチパターン検証環境のリセットスクリプト

echo "=== SQL アンチパターン検証環境のリセット ==="

# 1. 実行中のコンテナを停止
echo "1. コンテナを停止します..."
docker-compose down >/dev/null 2>&1

# 2. ボリュームも含めて削除（データベースを完全にリセット）
echo "2. データベースボリュームを削除します..."
docker-compose down -v >/dev/null 2>&1

# 3. コンテナを再起動
echo "3. コンテナを再起動します..."
docker-compose up -d >/dev/null 2>&1

# 4. データベースの準備が完了するまで待機
echo "4. データベースの準備を待機中..."
sleep 5

# PostgreSQL が完全に起動するまで待機
until docker-compose exec postgres pg_isready -U postgres > /dev/null 2>&1; do
    echo "   PostgreSQL の起動を待機中..."
    sleep 2
done

echo "5. データベースの準備が完了しました！"
echo ""
echo "次のコマンドでデータベースに接続できます："
echo "  docker-compose exec postgres psql -U postgres -d antipatterns"
echo ""
echo "各アンチパターンのサンプルを実行するには："
echo "  cd 12-index-shotgun"
echo "  docker-compose exec -T postgres psql -U postgres -d antipatterns < schema.sql"
echo "  docker-compose exec -T postgres psql -U postgres -d antipatterns < data.sql"