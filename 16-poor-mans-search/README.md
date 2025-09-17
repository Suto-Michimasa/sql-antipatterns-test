# 16章: プアマンズサーチエンジン (Poor Man's Search Engine)

## 概要
プアマンズサーチエンジンは、データベースの全文検索機能を使わずに、LIKE演算子とワイルドカードだけで検索機能を実装しようとするアンチパターンです。

## 問題点
- LIKE '%keyword%' は常にフルテーブルスキャンになる
- 大量データでのパフォーマンス劣化が著しい
- 複雑な検索要件（AND/OR、部分一致、類似検索）の実装が困難
- 多言語対応や正規化が困難

## 検証内容
1. LIKE検索と全文検索のパフォーマンス比較
2. データ量増加に伴う性能劣化の検証
3. 検索精度と柔軟性の比較
4. インデックスの効果測定

## 実行方法

```bash
# スキーマの作成
docker-compose exec -T postgres psql -U postgres -d antipatterns < schema.sql

# テストデータの投入
docker-compose exec -T postgres psql -U postgres -d antipatterns < data.sql

# アンチパターンの実行（LIKE検索）
docker-compose exec -T postgres psql -U postgres -d antipatterns < antipattern.sql

# ベンチマークの実行
docker-compose exec -T postgres psql -U postgres -d antipatterns < benchmark.sql

# 改善案の実行（全文検索）
docker-compose exec -T postgres psql -U postgres -d antipatterns < solution.sql
```