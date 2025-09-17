.PHONY: help up down reset clean \
	12-index-shotgun 12-index-shotgun-reset \
	16-poor-mans-search 16-poor-mans-search-reset \
	psql logs status

# デフォルトターゲット
help:
	@echo "SQL アンチパターン検証環境"
	@echo ""
	@echo "基本コマンド:"
	@echo "  make up              - Docker コンテナを起動"
	@echo "  make down            - Docker コンテナを停止"
	@echo "  make reset           - 環境を完全にリセット"
	@echo "  make clean           - すべてのデータを削除"
	@echo "  make psql            - PostgreSQL に接続"
	@echo "  make logs            - コンテナのログを表示"
	@echo "  make status          - コンテナの状態を確認"
	@echo ""
	@echo "アンチパターン検証:"
	@echo "  make 12-index-shotgun        - インデックスショットガンを実行"
	@echo "  make 12-index-shotgun-reset  - インデックスショットガンをリセット"
	@echo "  make 16-poor-mans-search     - プアマンズサーチエンジンを実行"
	@echo "  make 16-poor-mans-search-reset - プアマンズサーチエンジンをリセット"

# 基本操作
up:
	@docker-compose up -d >/dev/null 2>&1
	@echo "PostgreSQL が起動するまで待機中..."
	@sleep 5
	@echo "準備完了！"

down:
	@docker-compose down >/dev/null 2>&1
	@echo "コンテナを停止しました"

reset:
	@./reset.sh

clean:
	@docker-compose down -v >/dev/null 2>&1
	@echo "すべてのデータを削除しました"

psql:
	@docker-compose exec postgres psql -U postgres -d antipatterns

logs:
	@docker-compose logs -f postgres

status:
	@docker-compose ps

# 12章: インデックスショットガン
12-index-shotgun: up
	@echo "=== 12章: インデックスショットガン ==="
	@echo "スキーマを作成中..."
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 12-index-shotgun/schema.sql
	@echo "テストデータを投入中..."
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 12-index-shotgun/data.sql
	@echo "アンチパターンを実行中..."
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 12-index-shotgun/antipattern.sql
	@echo ""
	@echo "検証準備完了！"
	@echo "ベンチマークを実行: make 12-benchmark"
	@echo "改善案を実行: make 12-solution"

12-benchmark: up
	@echo "=== インデックスショットガン: ベンチマーク ==="
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 12-index-shotgun/benchmark.sql

12-solution: up
	@echo "=== インデックスショットガン: 改善案 ==="
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 12-index-shotgun/solution.sql

12-index-shotgun-reset: up
	@echo "インデックスショットガンをリセット中..."
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 12-index-shotgun/reset.sql
	@echo "リセット完了！"

# 16章: プアマンズサーチエンジン
16-poor-mans-search: up
	@echo "=== 16章: プアマンズサーチエンジン ==="
	@echo "スキーマを作成中..."
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 16-poor-mans-search/schema.sql
	@echo "テストデータを投入中..."
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 16-poor-mans-search/data.sql
	@echo "アンチパターンを実行中..."
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 16-poor-mans-search/antipattern.sql
	@echo ""
	@echo "検証準備完了！"
	@echo "ベンチマークを実行: make 16-benchmark"
	@echo "改善案を実行: make 16-solution"

16-benchmark: up
	@echo "=== プアマンズサーチエンジン: ベンチマーク ==="
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 16-poor-mans-search/benchmark.sql

16-solution: up
	@echo "=== プアマンズサーチエンジン: 改善案 ==="
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 16-poor-mans-search/solution.sql

16-poor-mans-search-reset: up
	@echo "プアマンズサーチエンジンをリセット中..."
	@docker-compose exec -T postgres psql -U postgres -d antipatterns < 16-poor-mans-search/reset.sql
	@echo "リセット完了！"

# すべてのアンチパターンを実行
all: 12-index-shotgun 16-poor-mans-search
	@echo ""
	@echo "すべてのアンチパターンの準備が完了しました！"