-- 実際のブログ記事のようなテストデータを生成
INSERT INTO poor_mans_articles (title, content, author, category, tags)
SELECT
    articles.title,
    articles.content,
    authors.author,
    categories.category,
    tags.tag_array
FROM (
    VALUES
    ('Understanding PostgreSQL Performance Tuning', 'PostgreSQL is a powerful database system that requires careful tuning for optimal performance. Key areas include query optimization, index management, and configuration parameters.'),
    ('Getting Started with Full-Text Search', 'Full-text search capabilities in PostgreSQL provide powerful search functionality. Unlike simple LIKE queries, full-text search offers linguistic support and ranking.'),
    ('Database Index Best Practices', 'Proper indexing is crucial for database performance. This guide covers when to create indexes, what types to use, and how to maintain them effectively.'),
    ('Advanced SQL Query Optimization', 'Learn advanced techniques for optimizing SQL queries including proper join strategies, subquery optimization, and effective use of window functions.'),
    ('PostgreSQL vs MySQL: A Detailed Comparison', 'Both PostgreSQL and MySQL are popular open-source databases. This article compares their features, performance characteristics, and use cases.'),
    ('Building Scalable Web Applications', 'Scalability is key for modern web applications. Database design, caching strategies, and query optimization all play crucial roles.'),
    ('Introduction to NoSQL Databases', 'NoSQL databases offer different data models compared to traditional relational databases. Understanding when to use them is important for architects.'),
    ('Data Warehousing Fundamentals', 'Data warehouses are designed for analytical queries. Learn about dimensional modeling, ETL processes, and query optimization for analytics.'),
    ('Real-Time Analytics with PostgreSQL', 'PostgreSQL can handle real-time analytics workloads with proper configuration. Techniques include partitioning, parallel queries, and materialized views.'),
    ('Database Security Best Practices', 'Security is paramount in database design. Cover authentication, authorization, encryption, and auditing strategies for PostgreSQL.')
) AS articles(title, content)
CROSS JOIN (
    VALUES 
    ('John Smith'), ('Jane Doe'), ('Mike Johnson'), ('Sarah Williams'), ('Tom Brown')
) AS authors(author)
CROSS JOIN (
    VALUES 
    ('Database'), ('Performance'), ('Tutorial'), ('Comparison'), ('Security')
) AS categories(category)
CROSS JOIN LATERAL (
    SELECT array_agg(tag) AS tag_array
    FROM unnest(ARRAY['postgresql', 'database', 'performance', 'optimization', 'sql', 'indexing', 'search']) AS tag
    WHERE random() > 0.5
) AS tags;

-- 大量のダミー記事を生成（検索性能テスト用）
INSERT INTO poor_mans_articles (title, content, author, category, tags)
SELECT
    'Article about ' || topics.topic || ' - Part ' || n,
    'This is a comprehensive article about ' || topics.topic || '. ' ||
    'It covers various aspects including implementation, best practices, and common pitfalls. ' ||
    'The content includes detailed examples and explanations about ' || topics.topic || ' in modern applications. ' ||
    'Key concepts discussed include performance optimization, scalability considerations, and practical use cases. ' ||
    'Whether you are a beginner or experienced developer, this guide will help you understand ' || topics.topic || ' better.',
    authors.author,
    categories.category,
    ARRAY[topics.topic, categories.category, 'technology']
FROM generate_series(1, 10000) n,
LATERAL (
    VALUES 
    ('machine learning'), ('artificial intelligence'), ('cloud computing'), 
    ('microservices'), ('kubernetes'), ('docker'), ('react'), ('angular'),
    ('vue.js'), ('node.js'), ('python'), ('java'), ('golang'), ('rust'),
    ('blockchain'), ('cryptocurrency'), ('data science'), ('big data'),
    ('devops'), ('continuous integration'), ('agile'), ('scrum')
) AS topics(topic),
LATERAL (
    SELECT (ARRAY['John Smith', 'Jane Doe', 'Mike Johnson', 'Sarah Williams', 'Tom Brown', 
                  'Lisa Anderson', 'Robert Taylor', 'Emily Davis', 'David Miller', 'Jennifer Wilson'])[floor(random() * 10 + 1)::int]
) AS authors(author),
LATERAL (
    SELECT (ARRAY['Technology', 'Programming', 'DevOps', 'Data Science', 'Web Development', 
                  'Mobile', 'Cloud', 'Security', 'AI/ML', 'Architecture'])[floor(random() * 10 + 1)::int]
) AS categories(category)
WHERE n % 500 = floor(random() * 500)::int;

-- 統計情報を更新
ANALYZE poor_mans_articles;