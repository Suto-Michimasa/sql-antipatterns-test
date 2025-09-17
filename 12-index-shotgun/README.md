# 12章: インデックスショットガン (Index Shotgun)

## 概要
インデックスショットガンは、パフォーマンス問題を解決しようとして、考えられるすべての列の組み合わせにインデックスを作成してしまうアンチパターンです。

## 問題点
- インデックスの維持コストが増大
- INSERT/UPDATE/DELETE の性能が著しく低下
- ストレージ容量の無駄遣い
- データベースのメンテナンス時間の増加

## 検証内容
1. 過剰なインデックスが書き込み性能に与える影響
2. 適切なインデックス戦略との比較
3. インデックスのメンテナンスコスト

## 実行方法

```bash
# スキーマの作成
docker-compose exec -T postgres psql -U postgres -d antipatterns < schema.sql

# テストデータの投入
docker-compose exec -T postgres psql -U postgres -d antipatterns < data.sql

# アンチパターンの実行（過剰なインデックス）
docker-compose exec -T postgres psql -U postgres -d antipatterns < antipattern.sql

# ベンチマークの実行
docker-compose exec -T postgres psql -U postgres -d antipatterns < benchmark.sql

# 改善案の実行
docker-compose exec -T postgres psql -U postgres -d antipatterns < solution.sql
```