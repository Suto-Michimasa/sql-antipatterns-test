-- アンチパターン: LIKE演算子による検索

-- 1. 基本的なLIKE検索（前方一致）
SELECT id, title, author, category
FROM poor_mans_articles
WHERE title LIKE 'PostgreSQL%'
LIMIT 10;

-- 2. 部分一致検索（最も遅い）
SELECT id, title, author, category
FROM poor_mans_articles
WHERE content LIKE '%performance%'
LIMIT 10;

-- 3. 複数条件のLIKE検索
SELECT id, title, author, category
FROM poor_mans_articles
WHERE (title LIKE '%database%' OR content LIKE '%database%')
  AND (title LIKE '%optimization%' OR content LIKE '%optimization%')
LIMIT 10;

-- 4. 大文字小文字を無視した検索
SELECT id, title, author, category
FROM poor_mans_articles
WHERE LOWER(content) LIKE LOWER('%PostgreSQL%')
LIMIT 10;

-- 5. 複数キーワードのAND検索（非効率）
SELECT id, title, author, category
FROM poor_mans_articles
WHERE content LIKE '%machine%'
  AND content LIKE '%learning%'
  AND content LIKE '%python%'
LIMIT 10;

-- 以下のコマンドで個別にLIKE検索のパフォーマンスを測定できます：
-- EXPLAIN (ANALYZE, BUFFERS, TIMING) 
-- SELECT COUNT(*) FROM poor_mans_articles WHERE content LIKE '%database%';