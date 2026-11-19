# data/db — 数据库（结构化落地层）

SQLite 主库：`data/db/warehouse.sqlite`。

把 `data/inbox/` 里的原始文件、`data/core/` 里的正式数据，抽取成**可查询的结构化表**。

## 定位：派生层，不是真源

| | 说明 |
| --- | --- |
| 是真源吗 | ❌ 不是。真源是 `data/core/` 与可重现的外部来源 |
| 能重建吗 | ✅ 必须能：`schema.sql` + 原始数据 + ingest 脚本，随时重建 |
| 进版本库吗 | ❌ 库文件不进（二进制 diff 无意义）；`schema.sql`、`migrations/` 必须进 |

这条决定了很多事：**正因为数据已经安全入库、可重建，那个 Excel 才敢删。**

## 选型：SQLite

| 方案 | 结论 |
| --- | --- |
| **SQLite 单文件** | ✅ 零运维、无服务、Python 内置、`sqlite3` CLI 直接查、单文件可拷走 |
| PostgreSQL / MySQL | ❌ 需要起服务、管端口、管账号，本工作区没有这个必要 |
| 文件塞 BLOB | ❌ 反模式。库存**结构化数据**，不当文件柜 |

## 表分层

| 前缀 | 含义 | 规则 |
| --- | --- | --- |
| `raw_` | 原样入库层 | **只追加**，不洗数据，字段统一 `TEXT` 保留原始值，便于事后追溯 |
| `clean_` | 清洗后层 | 可更新、可按行删除；每行必须能追到 `_ingest_id` |
| `v_` | 视图 | 只读，供查询与交付使用 |
| 系统表 | `ingest_log`、`schema_version` | 只由导入流程写入，不手改 |

命名：`raw_<来源简称>_<主题>`，如 `raw_gov_monthly_stats`；视图 `v_<主题>`。
**禁止**建 `tmp_`、`test_`、`bak_`、`xxx(1)` 这类表名。

## 每次导入必做五步

1. 应用/确认 schema：`sqlite3 data/db/warehouse.sqlite < data/db/schema.sql`
   （导入动作走 `python -m src.main ingest --inbox <目录>` 这样的**子命令**，不新建第二个程序入口，见 `src/readme.md`）
2. 建（或复用）`raw_` 表，分批插入原始行
3. 往 `ingest_log` **写一行**：时间、来源目录、表名、行数、校验和、会话 ID、Agent
4. 回 `data/inbox/<目录>/_inbox.md` 把状态改为 `已入库`
5. 按判定表决定原始文件删除或转正

缺任何一步都算导入未完成。

## 导入后必须自查

```bash
sqlite3 data/db/warehouse.sqlite "SELECT COUNT(*) FROM raw_xxx;"
sqlite3 data/db/warehouse.sqlite "SELECT id,table_name,row_count,ingested_at FROM ingest_log ORDER BY id DESC LIMIT 5;"
```

行数必须与来源文件一致。不一致就是导入出错，**不许「差不多就这样吧」**。

## schema 变更

- 不直接改已有表结构：新增 `migrations/NNNN-<描述>.sql`，同步提升 `schema_version`
- 变更必须同时回答：老数据怎么办（回填 / 重导 / 保留旧列）

## 红线

- 禁止 `DROP TABLE`、`TRUNCATE`、无条件 `DELETE` / `UPDATE`（需先备份并获明确授权）
- 禁止把 Excel / PDF / 图片等文件塞进 BLOB
- 禁止没有 `ingest_log` 记录的导入
- 禁止在库中存密钥、未脱敏个人信息
- 禁止建临时表/测试表来「先试试」
