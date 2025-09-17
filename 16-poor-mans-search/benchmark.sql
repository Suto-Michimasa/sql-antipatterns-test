-- プアマンズサーチエンジン: LIKE検索 vs 全文検索の比較

-- 比較用の関数
CREATE OR REPLACE FUNCTION compare_search_performance()
RETURNS TABLE(
    search_term TEXT,
    result_count INTEGER,
    like_ms NUMERIC,
    fulltext_ms NUMERIC,
    speedup TEXT
) AS $$
DECLARE
    start_time TIMESTAMP;
    like_time NUMERIC;
    ft_time NUMERIC;
    row_count INTEGER;
    search_terms TEXT[] := ARRAY['database', 'postgresql', 'performance optimization', 'machine learning'];
    term TEXT;
BEGIN
    -- 全文検索の準備（まだインデックスがない場合）
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE tablename = 'poor_mans_articles' 
        AND indexname = 'idx_articles_search_vector'
    ) THEN
        -- search_vectorカラムを更新
        UPDATE poor_mans_articles 
        SET search_vector = 
            setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
            setweight(to_tsvector('english', COALESCE(content, '')), 'B');
        
        -- インデックスを作成
        CREATE INDEX idx_articles_search_vector 
        ON poor_mans_articles USING gin(search_vector);
        
        ANALYZE poor_mans_articles;
    END IF;

    -- 各検索語でテスト
    FOREACH term IN ARRAY search_terms
    LOOP
        -- LIKE検索の測定
        start_time := clock_timestamp();
        SELECT COUNT(*) INTO row_count
        FROM poor_mans_articles
        WHERE content LIKE '%' || term || '%' 
           OR title LIKE '%' || term || '%';
        like_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                    EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

        -- 全文検索の測定
        start_time := clock_timestamp();
        SELECT COUNT(*) INTO row_count
        FROM poor_mans_articles
        WHERE search_vector @@ plainto_tsquery('english', term);
        ft_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                  EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

        RETURN QUERY SELECT 
            term,
            row_count,
            ROUND(like_time, 2),
            ROUND(ft_time, 2),
            CASE 
                WHEN ft_time > 0 THEN 
                    ROUND(like_time / ft_time, 1) || 'x 高速'
                ELSE 'N/A'
            END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 複雑なクエリの比較
CREATE OR REPLACE FUNCTION compare_complex_queries()
RETURNS TABLE(
    query_type TEXT,
    like_ms NUMERIC,
    fulltext_ms NUMERIC,
    speedup TEXT
) AS $$
DECLARE
    start_time TIMESTAMP;
    like_time NUMERIC;
    ft_time NUMERIC;
BEGIN
    -- 複数キーワードAND検索
    -- LIKE版
    start_time := clock_timestamp();
    PERFORM COUNT(*)
    FROM poor_mans_articles
    WHERE content LIKE '%machine%' 
      AND content LIKE '%learning%'
      AND content LIKE '%python%';
    like_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    -- 全文検索版
    start_time := clock_timestamp();
    PERFORM COUNT(*)
    FROM poor_mans_articles
    WHERE search_vector @@ to_tsquery('english', 'machine & learning & python');
    ft_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
              EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    RETURN QUERY SELECT 
        '3キーワードAND検索'::TEXT,
        ROUND(like_time, 2),
        ROUND(ft_time, 2),
        ROUND(like_time / NULLIF(ft_time, 0), 1) || 'x 高速';

    -- OR検索
    -- LIKE版
    start_time := clock_timestamp();
    PERFORM COUNT(*)
    FROM poor_mans_articles
    WHERE content LIKE '%kubernetes%' 
       OR content LIKE '%docker%'
       OR content LIKE '%container%';
    like_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    -- 全文検索版
    start_time := clock_timestamp();
    PERFORM COUNT(*)
    FROM poor_mans_articles
    WHERE search_vector @@ to_tsquery('english', 'kubernetes | docker | container');
    ft_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
              EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    RETURN QUERY SELECT 
        '3キーワードOR検索'::TEXT,
        ROUND(like_time, 2),
        ROUND(ft_time, 2),
        ROUND(like_time / NULLIF(ft_time, 0), 1) || 'x 高速';
END;
$$ LANGUAGE plpgsql;

-- ヘッダー
\echo '=== プアマンズサーチエンジン: パフォーマンス比較 ==='
\echo ''

-- データ量の確認
SELECT 
    COUNT(*) as "記事数",
    pg_size_pretty(pg_relation_size('poor_mans_articles')) as "テーブルサイズ"
FROM poor_mans_articles;

\echo ''
\echo '=== 単一キーワード検索の比較 ==='

-- 基本的な検索パフォーマンス比較
SELECT 
    search_term as "検索語",
    result_count as "ヒット件数",
    like_ms || ' ms' as "LIKE検索",
    fulltext_ms || ' ms' as "全文検索",
    speedup as "性能向上"
FROM compare_search_performance()
ORDER BY like_ms DESC;

\echo ''
\echo '=== 複雑なクエリの比較 ==='

-- 複雑なクエリの比較
SELECT 
    query_type as "クエリタイプ",
    like_ms || ' ms' as "LIKE検索",
    fulltext_ms || ' ms' as "全文検索",
    speedup as "性能向上"
FROM compare_complex_queries();

\echo ''
\echo '=== インデックスサイズ ==='

-- インデックスサイズの比較
SELECT 
    indexname as "インデックス名",
    pg_size_pretty(pg_relation_size(schemaname||'.'||indexname)) as "サイズ"
FROM pg_indexes
WHERE tablename = 'poor_mans_articles'
  AND indexname = 'idx_articles_search_vector';

-- クリーンアップ
DROP FUNCTION compare_search_performance();
DROP FUNCTION compare_complex_queries();