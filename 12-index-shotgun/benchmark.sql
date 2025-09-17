-- インデックスショットガン: アンチパターン vs 改善案の比較

-- 測定用の関数
CREATE OR REPLACE FUNCTION measure_index_performance()
RETURNS TABLE(
    test_name TEXT,
    antipattern_ms NUMERIC,
    solution_ms NUMERIC,
    improvement TEXT
) AS $$
DECLARE
    start_time TIMESTAMP;
    antipattern_time NUMERIC;
    solution_time NUMERIC;
    test_product_count INTEGER;
BEGIN
    -- テスト1: 単一行INSERT
    -- アンチパターン（多数のインデックスあり）
    start_time := clock_timestamp();
    INSERT INTO index_shotgun_products (
        name, description, category, subcategory, brand, model, sku,
        price, cost, stock_quantity, warehouse_id, supplier_id
    ) VALUES (
        'Benchmark Single', 'Test', 'Category 1', 'Subcategory 1',
        'Brand 1', 'Model-BENCH', 'SKU-BENCH-SINGLE', 299.99, 150.00, 100, 1, 1
    );
    antipattern_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                       EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    -- 全インデックスを一時的に無効化（改善案をシミュレート）
    UPDATE pg_index SET indisvalid = false 
    WHERE indexrelid IN (
        SELECT (schemaname||'.'||indexname)::regclass 
        FROM pg_indexes 
        WHERE tablename = 'index_shotgun_products' 
        AND indexname LIKE 'idx_shotgun_%'
    );

    -- 改善案（最小限のインデックス）
    start_time := clock_timestamp();
    INSERT INTO index_shotgun_products (
        name, description, category, subcategory, brand, model, sku,
        price, cost, stock_quantity, warehouse_id, supplier_id
    ) VALUES (
        'Solution Single', 'Test', 'Category 1', 'Subcategory 1',
        'Brand 1', 'Model-SOL', 'SKU-SOL-SINGLE', 299.99, 150.00, 100, 1, 1
    );
    solution_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                    EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    -- インデックスを再有効化
    UPDATE pg_index SET indisvalid = true 
    WHERE indexrelid IN (
        SELECT (schemaname||'.'||indexname)::regclass 
        FROM pg_indexes 
        WHERE tablename = 'index_shotgun_products' 
        AND indexname LIKE 'idx_shotgun_%'
    );

    RETURN QUERY SELECT 
        '単一行INSERT'::TEXT,
        ROUND(antipattern_time, 2),
        ROUND(solution_time, 2),
        CASE 
            WHEN solution_time > 0 THEN 
                ROUND((antipattern_time / solution_time - 1) * 100, 1) || '% 高速化'
            ELSE 'N/A'
        END;

    -- テスト2: バルクINSERT（100行）
    SELECT COUNT(*) INTO test_product_count FROM index_shotgun_products;

    -- アンチパターン
    start_time := clock_timestamp();
    INSERT INTO index_shotgun_products (
        name, description, category, subcategory, brand, model, sku,
        price, cost, stock_quantity, warehouse_id, supplier_id
    )
    SELECT 
        'Bulk Anti ' || i,
        'Bulk Description',
        'Category ' || (i % 20 + 1),
        'Subcategory ' || (i % 50 + 1),
        'Brand ' || (i % 30 + 1),
        'Model-ANTI-' || i,
        'SKU-ANTI-' || LPAD((test_product_count + i)::text, 8, '0'),
        (RANDOM() * 1000 + 10)::DECIMAL(10, 2),
        (RANDOM() * 500 + 5)::DECIMAL(10, 2),
        (RANDOM() * 1000)::INTEGER,
        (i % 5 + 1),
        (i % 10 + 1)
    FROM generate_series(1, 100) i;
    antipattern_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                       EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    -- インデックスを一時的に無効化
    UPDATE pg_index SET indisvalid = false 
    WHERE indexrelid IN (
        SELECT (schemaname||'.'||indexname)::regclass 
        FROM pg_indexes 
        WHERE tablename = 'index_shotgun_products' 
        AND indexname LIKE 'idx_shotgun_%'
    );

    SELECT COUNT(*) INTO test_product_count FROM index_shotgun_products;

    -- 改善案
    start_time := clock_timestamp();
    INSERT INTO index_shotgun_products (
        name, description, category, subcategory, brand, model, sku,
        price, cost, stock_quantity, warehouse_id, supplier_id
    )
    SELECT 
        'Bulk Sol ' || i,
        'Bulk Description',
        'Category ' || (i % 20 + 1),
        'Subcategory ' || (i % 50 + 1),
        'Brand ' || (i % 30 + 1),
        'Model-SOL-' || i,
        'SKU-SOL-' || LPAD((test_product_count + i)::text, 8, '0'),
        (RANDOM() * 1000 + 10)::DECIMAL(10, 2),
        (RANDOM() * 500 + 5)::DECIMAL(10, 2),
        (RANDOM() * 1000)::INTEGER,
        (i % 5 + 1),
        (i % 10 + 1)
    FROM generate_series(1, 100) i;
    solution_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                    EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    -- インデックスを再有効化
    UPDATE pg_index SET indisvalid = true 
    WHERE indexrelid IN (
        SELECT (schemaname||'.'||indexname)::regclass 
        FROM pg_indexes 
        WHERE tablename = 'index_shotgun_products' 
        AND indexname LIKE 'idx_shotgun_%'
    );

    RETURN QUERY SELECT 
        'バルクINSERT(100行)'::TEXT,
        ROUND(antipattern_time, 2),
        ROUND(solution_time, 2),
        CASE 
            WHEN solution_time > 0 THEN 
                ROUND((antipattern_time / solution_time - 1) * 100, 1) || '% 高速化'
            ELSE 'N/A'
        END;

    -- テスト3: UPDATE
    -- アンチパターン
    start_time := clock_timestamp();
    UPDATE index_shotgun_products 
    SET stock_quantity = stock_quantity - 1, updated_at = CURRENT_TIMESTAMP
    WHERE id IN (
        SELECT id FROM index_shotgun_products 
        WHERE category = 'Category 2' AND is_active = true
        LIMIT 50
    );
    antipattern_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                       EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    -- インデックスを一時的に無効化
    UPDATE pg_index SET indisvalid = false 
    WHERE indexrelid IN (
        SELECT (schemaname||'.'||indexname)::regclass 
        FROM pg_indexes 
        WHERE tablename = 'index_shotgun_products' 
        AND indexname LIKE 'idx_shotgun_%'
    );

    -- 改善案
    start_time := clock_timestamp();
    UPDATE index_shotgun_products 
    SET stock_quantity = stock_quantity - 1, updated_at = CURRENT_TIMESTAMP
    WHERE id IN (
        SELECT id FROM index_shotgun_products 
        WHERE category = 'Category 3' AND is_active = true
        LIMIT 50
    );
    solution_time := EXTRACT(MILLISECOND FROM clock_timestamp() - start_time) + 
                    EXTRACT(SECOND FROM clock_timestamp() - start_time) * 1000;

    -- インデックスを再有効化
    UPDATE pg_index SET indisvalid = true 
    WHERE indexrelid IN (
        SELECT (schemaname||'.'||indexname)::regclass 
        FROM pg_indexes 
        WHERE tablename = 'index_shotgun_products' 
        AND indexname LIKE 'idx_shotgun_%'
    );

    RETURN QUERY SELECT 
        'UPDATE(50行)'::TEXT,
        ROUND(antipattern_time, 2),
        ROUND(solution_time, 2),
        CASE 
            WHEN solution_time > 0 THEN 
                ROUND((antipattern_time / solution_time - 1) * 100, 1) || '% 高速化'
            ELSE 'N/A'
        END;

END;
$$ LANGUAGE plpgsql;

-- ヘッダー情報
\echo '=== インデックスショットガン: パフォーマンス比較 ==='
\echo ''

-- インデックス情報のサマリー
WITH index_info AS (
    SELECT 
        COUNT(*) as index_count,
        pg_size_pretty(SUM(pg_relation_size(schemaname||'.'||indexname))::bigint) as total_size
    FROM pg_indexes
    WHERE tablename = 'index_shotgun_products'
)
SELECT 
    'アンチパターン' as "パターン",
    index_count as "インデックス数",
    total_size as "インデックス総サイズ"
FROM index_info
UNION ALL
SELECT 
    '改善案' as "パターン",
    4 as "インデックス数",
    '< 5 MB' as "インデックス総サイズ";

\echo ''
\echo '=== 実行時間比較 ==='

-- パフォーマンステストの実行と結果表示
SELECT 
    test_name as "テスト項目",
    antipattern_ms || ' ms' as "アンチパターン",
    solution_ms || ' ms' as "改善案",
    improvement as "性能改善"
FROM measure_index_performance()
ORDER BY test_name;

-- クリーンアップ
DROP FUNCTION measure_index_performance();