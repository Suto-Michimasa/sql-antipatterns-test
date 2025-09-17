-- アンチパターン: 過剰なインデックスの作成
-- 考えられるすべての検索パターンに対してインデックスを作成

-- 単一列インデックス（すべての列に対して）
CREATE INDEX idx_shotgun_name ON index_shotgun_products(name);
CREATE INDEX idx_shotgun_description ON index_shotgun_products(description);
CREATE INDEX idx_shotgun_category ON index_shotgun_products(category);
CREATE INDEX idx_shotgun_subcategory ON index_shotgun_products(subcategory);
CREATE INDEX idx_shotgun_brand ON index_shotgun_products(brand);
CREATE INDEX idx_shotgun_model ON index_shotgun_products(model);
CREATE INDEX idx_shotgun_price ON index_shotgun_products(price);
CREATE INDEX idx_shotgun_cost ON index_shotgun_products(cost);
CREATE INDEX idx_shotgun_stock ON index_shotgun_products(stock_quantity);
CREATE INDEX idx_shotgun_warehouse ON index_shotgun_products(warehouse_id);
CREATE INDEX idx_shotgun_supplier ON index_shotgun_products(supplier_id);
CREATE INDEX idx_shotgun_active ON index_shotgun_products(is_active);
CREATE INDEX idx_shotgun_featured ON index_shotgun_products(is_featured);
CREATE INDEX idx_shotgun_created ON index_shotgun_products(created_at);
CREATE INDEX idx_shotgun_updated ON index_shotgun_products(updated_at);
CREATE INDEX idx_shotgun_sold ON index_shotgun_products(last_sold_at);
CREATE INDEX idx_shotgun_views ON index_shotgun_products(view_count);
CREATE INDEX idx_shotgun_rating ON index_shotgun_products(rating);
CREATE INDEX idx_shotgun_reviews ON index_shotgun_products(review_count);

-- 複合インデックス（よくある組み合わせすべて）
CREATE INDEX idx_shotgun_cat_subcat ON index_shotgun_products(category, subcategory);
CREATE INDEX idx_shotgun_cat_brand ON index_shotgun_products(category, brand);
CREATE INDEX idx_shotgun_cat_price ON index_shotgun_products(category, price);
CREATE INDEX idx_shotgun_brand_model ON index_shotgun_products(brand, model);
CREATE INDEX idx_shotgun_active_cat ON index_shotgun_products(is_active, category);
CREATE INDEX idx_shotgun_active_brand ON index_shotgun_products(is_active, brand);
CREATE INDEX idx_shotgun_active_price ON index_shotgun_products(is_active, price);
CREATE INDEX idx_shotgun_warehouse_cat ON index_shotgun_products(warehouse_id, category);
CREATE INDEX idx_shotgun_cat_subcat_brand ON index_shotgun_products(category, subcategory, brand);
CREATE INDEX idx_shotgun_active_cat_price ON index_shotgun_products(is_active, category, price);
CREATE INDEX idx_shotgun_active_featured_cat ON index_shotgun_products(is_active, is_featured, category);
CREATE INDEX idx_shotgun_warehouse_active_cat ON index_shotgun_products(warehouse_id, is_active, category);

-- 部分インデックス（条件付き）
CREATE INDEX idx_shotgun_active_only ON index_shotgun_products(id) WHERE is_active = true;
CREATE INDEX idx_shotgun_featured_only ON index_shotgun_products(id) WHERE is_featured = true;
CREATE INDEX idx_shotgun_low_stock ON index_shotgun_products(id) WHERE stock_quantity < 10;
CREATE INDEX idx_shotgun_high_rating ON index_shotgun_products(id) WHERE rating >= 4.0;

-- インデックスの統計情報を確認
SELECT 
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(schemaname||'.'||indexname)) AS index_size
FROM pg_indexes
WHERE tablename = 'index_shotgun_products'
ORDER BY pg_relation_size(schemaname||'.'||indexname) DESC;