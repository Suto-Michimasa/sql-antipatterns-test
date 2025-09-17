-- 16章: プアマンズサーチエンジンのリセット

-- インデックスを削除
DROP INDEX IF EXISTS idx_articles_search_vector;
DROP INDEX IF EXISTS idx_articles_title_trgm;

-- トリガーを削除
DROP TRIGGER IF EXISTS articles_search_update ON poor_mans_articles;
DROP FUNCTION IF EXISTS articles_search_trigger();

-- 測定関数を削除（benchmark-compare.sql で作成された関数）
DROP FUNCTION IF EXISTS compare_search_performance();
DROP FUNCTION IF EXISTS compare_complex_queries();

-- テーブルを削除
DROP TABLE IF EXISTS poor_mans_articles;

-- ビューを削除
DROP VIEW IF EXISTS index_usage_stats;

-- 検証を最初からやり直す場合は、schema.sql から実行してください