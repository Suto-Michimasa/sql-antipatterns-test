-- インデックスショットガン検証用テーブル
DROP TABLE IF EXISTS index_shotgun_products;

CREATE TABLE index_shotgun_products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    subcategory VARCHAR(50),
    brand VARCHAR(50),
    model VARCHAR(50),
    sku VARCHAR(50) UNIQUE,
    price DECIMAL(10, 2),
    cost DECIMAL(10, 2),
    stock_quantity INTEGER DEFAULT 0,
    warehouse_id INTEGER,
    supplier_id INTEGER,
    is_active BOOLEAN DEFAULT true,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_sold_at TIMESTAMP,
    view_count INTEGER DEFAULT 0,
    rating DECIMAL(3, 2),
    review_count INTEGER DEFAULT 0
);