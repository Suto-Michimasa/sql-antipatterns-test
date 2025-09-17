# SQL アンチパターン検証環境

SQL アンチパターンをローカルで検証するためのサンドボックス環境です。

## 必要なもの

- Docker
- Docker Compose
- Make

## クイックスタート

```bash
# ヘルプを表示
make help

# 環境を起動
make up

# 12章: インデックスショットガンの検証
make 12-index-shotgun
make 12-benchmark

# 16章: プアマンズサーチエンジンの検証  
make 16-poor-mans-search
make 16-benchmark

# 環境をリセット
make reset
```

## アンチパターン一覧

| 章 | アンチパターン名 | 検証内容 |
|---|---|---|
| 12 | インデックスショットガン | 過剰なインデックスによる書き込み性能低下 |
| 16 | プアマンズサーチエンジン | LIKE検索 vs PostgreSQL全文検索の性能比較 |

## 主要コマンド

```bash
make help                    # ヘルプを表示
make up                      # Docker起動
make down                    # Docker停止
make reset                   # 環境リセット
make psql                    # PostgreSQLに接続

make 12-index-shotgun        # 12章セットアップ
make 12-benchmark            # 12章ベンチマーク実行
make 12-solution             # 12章改善案実行
make 12-index-shotgun-reset  # 12章リセット

make 16-poor-mans-search     # 16章セットアップ
make 16-benchmark            # 16章ベンチマーク実行
make 16-solution             # 16章改善案実行
make 16-poor-mans-search-reset # 16章リセット
```

## ベンチマーク結果の例

### 12章: インデックスショットガン
```
=== 実行時間比較 ===
     テスト項目      | アンチパターン |  改善案  |   性能改善
---------------------+----------------+----------+---------------
 単一行INSERT        | 4.38 ms        | 1.29 ms  | 240.0% 高速化
 バルクINSERT(100行) | 24.78 ms       | 13.73 ms | 80.5% 高速化
```

### 16章: プアマンズサーチエンジン
```
=== 単一キーワード検索の比較 ===
    検索語    | LIKE検索 | 全文検索 | 性能向上
--------------+----------+----------+-----------
 postgresql   | 0.78 ms  | 0.20 ms  | 4.0x 高速
 database     | 1.61 ms  | 0.42 ms  | 3.9x 高速
```