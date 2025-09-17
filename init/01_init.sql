-- 初期データベース設定
-- 拡張機能の有効化
CREATE EXTENSION IF NOT EXISTS pg_trgm; -- 類似度検索用
CREATE EXTENSION IF NOT EXISTS unaccent; -- アクセント記号の除去用

-- 共通的な設定
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;