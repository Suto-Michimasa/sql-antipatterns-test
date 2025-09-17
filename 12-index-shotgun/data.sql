-- テストデータ生成
INSERT INTO index_shotgun_products (
    name, description, category, subcategory, brand, model, sku,
    price, cost, stock_quantity, warehouse_id, supplier_id,
    is_active, is_featured, rating, review_count
)
SELECT 
    'Product ' || i,
    'Description for product ' || i,
    'Category ' || (i % 20 + 1),
    'Subcategory ' || (i % 50 + 1),
    'Brand ' || (i % 30 + 1),
    'Model ' || i,
    'SKU-' || LPAD(i::text, 8, '0'),
    (RANDOM() * 1000 + 10)::DECIMAL(10, 2),
    (RANDOM() * 500 + 5)::DECIMAL(10, 2),
    (RANDOM() * 1000)::INTEGER,
    (i % 5 + 1),
    (i % 10 + 1),
    RANDOM() > 0.1,
    RANDOM() > 0.9,
    (RANDOM() * 4 + 1)::DECIMAL(3, 2),
    (RANDOM() * 100)::INTEGER
FROM generate_series(1, 100000) i;