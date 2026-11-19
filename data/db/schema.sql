-- data/db/schema.sql
-- 应用方式：sqlite3 data/db/warehouse.sqlite < data/db/schema.sql
-- 规则：已有表结构不得直接修改，新增 migrations/NNNN-<描述>.sql 并提升 schema_version

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- ---------------------------------------------------------------- 版本
CREATE TABLE IF NOT EXISTS schema_version (
    version    INTEGER PRIMARY KEY,
    applied_at TEXT NOT NULL,
    note       TEXT
);

INSERT OR IGNORE INTO schema_version (version, applied_at, note)
VALUES (1, date('now'), 'v1 初始 schema：ingest_log / raw 层 / clean 层模板');

-- ---------------------------------------------------------------- 导入台账
-- 每次导入必须写一行；没有记录的导入视为未完成
CREATE TABLE IF NOT EXISTS ingest_log (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    ingested_at  TEXT    NOT NULL,           -- ISO8601，如 2026-11-19T14:30:00
    source_dir   TEXT    NOT NULL,           -- data/inbox/20261119-xxx/
    source_file  TEXT,                       -- 原始文件名
    table_name   TEXT    NOT NULL,           -- 落进哪张表
    row_count    INTEGER NOT NULL,
    checksum     TEXT,                       -- 来源文件校验和（sha256）
    session_id   TEXT    NOT NULL,           -- 与 项目进度.md 对齐
    agent        TEXT,                       -- 主理人 / Agent 名
    note         TEXT
);

CREATE INDEX IF NOT EXISTS idx_ingest_log_table ON ingest_log (table_name, ingested_at);

-- ---------------------------------------------------------------- raw 层（模板）
-- 原样入库：字段统一 TEXT，不做类型转换，只追加不修改
CREATE TABLE IF NOT EXISTS raw_example (
    _ingest_id INTEGER NOT NULL REFERENCES ingest_log (id),
    _row_no    INTEGER NOT NULL,             -- 来源文件中的行号，便于回查
    col_a      TEXT,
    col_b      TEXT,
    PRIMARY KEY (_ingest_id, _row_no)
);

-- ---------------------------------------------------------------- clean 层（模板）
-- 清洗后：可更新、可按行删除，但每行仍可追溯到来源导入批次
CREATE TABLE IF NOT EXISTS clean_example (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    _ingest_id INTEGER NOT NULL REFERENCES ingest_log (id),
    col_a      TEXT,
    col_b      REAL,
    updated_at TEXT
);
