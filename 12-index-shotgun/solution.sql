-- 改善案: 適切なインデックス戦略

-- 1. すべての過剰なインデックスを削除
DO $$
DECLARE
    idx_name text;
BEGIN
    FOR idx_name IN 
        SELECT indexname 
        FROM pg_indexes 
        WHERE tablename = 'index_shotgun_products' 
        AND indexname LIKE 'idx_shotgun_%'
    LOOP
        EXECUTE 'DROP INDEX IF EXISTS ' || idx_name;
    END LOOP;
END $$;

-- 2. クエリログ分析に基づいた必要最小限のインデックスのみ作成
-- 実際の使用パターンに基づいて選択

-- 頻繁に使用される検索条件
CREATE INDEX idx_products_active_category ON index_shotgun_products(is_active, category) 
WHERE is_active = true;

-- 価格範囲検索（B-treeインデックス）
CREATE INDEX idx_products_price ON index_shotgun_products(price) 
WHERE is_active = true;

-- 在庫管理用
CREATE INDEX idx_products_low_stock ON index_shotgun_products(warehouse_id, stock_quantity) 
WHERE stock_quantity < 10 AND is_active = true;

-- フルテキスト検索用（製品名と説明）
CREATE INDEX idx_products_search ON index_shotgun_products 
USING gin(to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- 3. インデックスの効果を確認
SELECT 
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
FROM pg_stat_user_indexes
WHERE tablename = 'index_shotgun_products'
ORDER BY idx_scan DESC;

-- 4. 改善後のベンチマーク
\timing on

-- INSERT性能（改善後）
EXPLAIN (ANALYZE, BUFFERS, TIMING)
INSERT INTO index_shotgun_products (
    name, description, category, subcategory, brand, model, sku,
    price, cost, stock_quantity, warehouse_id, supplier_id
) VALUES (
    'Optimized Product', 'Optimized Description', 'Category 1', 'Subcategory 1',
    'Brand 1', 'Model OPT-1', 'SKU-OPT-001', 199.99, 100.00, 50, 1, 1
);

-- UPDATE性能（改善後）
EXPLAIN (ANALYZE, BUFFERS, TIMING)
UPDATE index_shotgun_products 
SET 
    stock_quantity = stock_quantity - 1,
    updated_at = CURRENT_TIMESTAMP
WHERE id = (SELECT id FROM index_shotgun_products LIMIT 1);

-- 5. インデックス使用状況のモニタリング設定
CREATE OR REPLACE VIEW index_usage_stats AS
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
    idx_scan,
    CASE 
        WHEN idx_scan = 0 THEN 'UNUSED'
        WHEN idx_scan < 10 THEN 'RARELY USED'
        WHEN idx_scan < 100 THEN 'OCCASIONALLY USED'
        ELSE 'FREQUENTLY USED'
    END AS usage_category,
    ROUND((idx_scan::numeric / GREATEST(seq_scan + idx_scan, 1) * 100), 2) AS index_usage_percent
FROM pg_stat_user_indexes
JOIN pg_stat_user_tables USING (schemaname, tablename)
WHERE tablename = 'index_shotgun_products'
ORDER BY idx_scan DESC;

-- 使用統計の確認
SELECT * FROM index_usage_stats;

\timing off

-- 推奨事項
COMMENT ON TABLE index_shotgun_products IS 'インデックス戦略:
1. 実際のクエリパターンを分析してからインデックスを作成
2. 未使用のインデックスは定期的に削除
3. 複合インデックスは選択性の高い列を先頭に配置
4. 部分インデックスを活用して、インデックスサイズを削減
5. pg_stat_user_indexesを定期的に監視';