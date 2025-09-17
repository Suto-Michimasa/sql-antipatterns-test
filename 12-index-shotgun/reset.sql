-- 12章: インデックスショットガンのリセット

-- すべてのインデックスを削除
DO $$
DECLARE
    idx_name text;
BEGIN
    FOR idx_name IN 
        SELECT indexname 
        FROM pg_indexes 
        WHERE tablename = 'index_shotgun_products' 
        AND indexname NOT LIKE '%_pkey'  -- プライマリキーは除外
    LOOP
        EXECUTE 'DROP INDEX IF EXISTS ' || idx_name;
    END LOOP;
END $$;

-- テーブルを削除して再作成
DROP TABLE IF EXISTS index_shotgun_products;

-- 測定関数を削除（benchmark-compare.sql で作成された関数）
DROP FUNCTION IF EXISTS measure_index_performance();

-- 検証を最初からやり直す場合は、schema.sql から実行してください