-- 改善案: PostgreSQLの全文検索機能を使用

-- 1. 全文検索用のインデックスとトリガーを設定
-- search_vector列を自動更新するトリガー
CREATE OR REPLACE FUNCTION articles_search_trigger() RETURNS trigger AS $$
BEGIN
    NEW.search_vector := 
        setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
        setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'B') ||
        setweight(to_tsvector('english', COALESCE(NEW.author, '')), 'C') ||
        setweight(to_tsvector('english', COALESCE(NEW.category, '')), 'C');
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER articles_search_update
    BEFORE INSERT OR UPDATE ON poor_mans_articles
    FOR EACH ROW EXECUTE FUNCTION articles_search_trigger();

-- 既存データのsearch_vectorを更新
UPDATE poor_mans_articles SET id = id;

-- GINインデックスを作成（全文検索用）
CREATE INDEX idx_articles_search_vector ON poor_mans_articles USING gin(search_vector);

-- 2. 全文検索の例
-- 単一キーワード検索
SELECT id, title, author, category,
       ts_rank(search_vector, to_tsquery('english', 'postgresql')) AS rank
FROM poor_mans_articles
WHERE search_vector @@ to_tsquery('english', 'postgresql')
ORDER BY rank DESC
LIMIT 10;

-- 複数キーワードのAND検索
SELECT id, title, author, category,
       ts_rank(search_vector, to_tsquery('english', 'machine & learning & python')) AS rank
FROM poor_mans_articles
WHERE search_vector @@ to_tsquery('english', 'machine & learning & python')
ORDER BY rank DESC
LIMIT 10;

-- フレーズ検索
SELECT id, title, author, category
FROM poor_mans_articles
WHERE search_vector @@ phraseto_tsquery('english', 'performance optimization')
LIMIT 10;

-- 3. パフォーマンス比較
-- 以下のコマンドで全文検索のパフォーマンスを測定できます：
-- EXPLAIN (ANALYZE, BUFFERS, TIMING)
-- SELECT COUNT(*) FROM poor_mans_articles 
-- WHERE search_vector @@ plainto_tsquery('english', 'database');

-- 5. 高度な検索機能
-- 類似度検索（trigram使用）
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX idx_articles_title_trgm ON poor_mans_articles USING gin(title gin_trgm_ops);

-- タイポを含む検索（類似度検索）
SELECT id, title, similarity(title, 'postgrsql') AS sim
FROM poor_mans_articles
WHERE title % 'postgrsql'  -- 類似度閾値を超える結果
ORDER BY sim DESC
LIMIT 10;

-- 6. 検索結果のハイライト表示
SELECT id, 
       ts_headline('english', title, to_tsquery('english', 'postgresql'),
                   'StartSel=<mark>, StopSel=</mark>') AS highlighted_title,
       author, category
FROM poor_mans_articles
WHERE search_vector @@ to_tsquery('english', 'postgresql')
LIMIT 5;
