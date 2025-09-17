-- プアマンズサーチエンジン検証用テーブル
DROP TABLE IF EXISTS poor_mans_articles;

CREATE TABLE poor_mans_articles (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    content TEXT NOT NULL,
    author VARCHAR(100),
    category VARCHAR(50),
    tags TEXT[],
    published_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    view_count INTEGER DEFAULT 0,
    language VARCHAR(10) DEFAULT 'en',
    
    -- 全文検索用の列（後で使用）
    search_vector tsvector
);

