# 宽宏 · 项目工作区

一个为 **Agent 协作**设计的工作区：主理人（Manager）拆计划与验收，Subagent 并行执行。

**第一次进来（人或 Agent）请按顺序读**：本文件 → [`AGENTS.md`](AGENTS.md) → 需要动手的那一层目录 readme。

## 目录地图

| 目录 | 放什么 | 一句话职责 | 说明 |
| --- | --- | --- | --- |
| `src/` | Python 主程序 | 读输入，跑出产物 | [readme](src/readme.md) |
| `data/core/` | 正式输入数据 | **唯一真源**，落盘即冻结 | [readme](data/core/readme.md) |
| `data/inbox/` | 外来文件收件箱 | 落地即建目录，必须写终态 | [readme](data/inbox/readme.md) |
| `data/db/` | SQLite 结构化库 | 派生层，可重建，导入必登台账 | [readme](data/db/readme.md) |
| `data/temp/` | 程序中间数据 | 可随时清空重建 | [readme](data/temp/readme.md) |
| `temp_text/` | 一次性文本 | 草稿纸，程序不依赖 | [readme](temp_text/readme.md) |
| `output/` | 最终交付物 | 成品 + `manifest.md` | [readme](output/readme.md) |
| `log/` | 运行日志 | 机器怎么跑的 | [readme](log/readme.md) |
| `docs/specs/` | 规格与记忆 | 做什么、为什么、踩过什么坑 | [readme](docs/specs/readme.md) |
| `docs/plan/` | 执行计划 | 怎么走到那儿 | [readme](docs/plan/readme.md) |
| `docs/web_search/` | 检索证据 | 结论的来源可追溯 | [readme](docs/web_search/readme.md) |

## 数据流

```
              ┌──────────────────────────────────────────┐
              │  docs/specs/  真规则（做什么 / 为什么）    │
              │  docs/plan/   路径（怎么走到那儿）         │
              └───────────────────┬──────────────────────┘
                                  │ 指导
   data/core/  ──(只读)──▶  src/  ──▶  output/  ──▶  交付
      真源                 主程序      成品 + manifest.md
        ▲                     │
        │ 转正（来源不可重现）   ├──▶  data/temp/   中间数据（可重建、可清空）
        │                     └──▶  log/         运行轨迹（靠会话 ID 对齐）
        │
  data/inbox/  ──(来源可重现)──▶  data/db/warehouse.sqlite  ──▶  删原始文件
  外来文件收件箱                   结构化落地层（raw_ + ingest_log）

   temp_text/   人工阅读的原始文本 —— 草稿纸，不进数据流
```

## 四条核心原则

1. **单一真源**：`data/core/` 只读。要改结果，回源头改数据、重跑程序，**不改产物**。
2. **唯一入口**：`src/main.py` 是唯一可执行入口，参数一律外部传入。
3. **证据说话**：交付必须带 `manifest.md`，验收结论可复现；口头「已完成」不算完成。
4. **外来必入箱**：任何从外部拿到的文件先进 `data/inbox/`，能重现的删、不能重现的转正，**不许散落、不许「先放着」**。

## 开工前检查清单

- [ ] 读过 `AGENTS.md`，知道自己的写入权限边界
- [ ] 看过 `docs/specs/memory.md`，确认不重踩已知的坑
- [ ] 找到当前 `docs/plan/` 里的计划，明确本次任务的验收标准
- [ ] 确认输入在 `data/core/`（或先在 `data/inbox/` 收件）；产物要落到 `output/<日期>-<主题>/`
- [ ] 需要外部文件时，先建 `data/inbox/<YYYYMMDD>-<用途>/`，不随手乱放

## 收尾检查清单

- [ ] 已按规范追加 `docs/specs/项目进度.md` 条目（含时间与会话 ID）
- [ ] 自己的 `data/inbox/` 收件目录已写终态，原始文件已按判定表删除或转正
- [ ] 导入库的数据在 `ingest_log` 有记录，行数与来源一致
- [ ] 踩到的坑已写入 `docs/specs/memory.md`
- [ ] 自己产生的临时文件已清理（只删自己建的）
- [ ] 交付目录内 `manifest.md` 存在且填写完整
