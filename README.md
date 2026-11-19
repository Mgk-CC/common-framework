# 项目工作区

一个为 **Agent 协作**设计的工作区：主理人（Manager）拆计划与验收，Subagent 并行执行。

仓库：`Mgk-CC/common-framework`（私有）

> **本文件是唯一权威规则来源。**
> `AGENTS.md` 只是各 Agent 自己维护的增量经验，两者冲突时**以本文件为准**。

## 开工必读（按顺序，缺一不可）

1. `README.md` —— 本文件：目录地图、数据流、写入权限、红线
2. `AGENTS.md` —— 其他 Agent 留下的增量经验（可自由增补）
3. `docs/specs/项目总方案以及框架.md` —— 目标、范围、术语
4. `docs/specs/memory.md` —— 已知的坑，别重踩
5. `docs/plan/<当前计划>.md` —— 本次要走的路径与验收标准
6. `docs/specs/项目进度.md` 末尾若干条 —— 上一棒跑到哪了
7. 要碰数据时追加：`data/inbox/readme.md`（外来文件怎么收）、`data/db/readme.md`（入库规范）

开工自检：

- [ ] 清楚自己的写入权限边界（见「写入权限」）
- [ ] 确认不重踩 `memory.md` 里已记录的坑
- [ ] 定位到当前计划，明确本次任务的验收标准
- [ ] 需要外部文件时，先建 `data/inbox/<YYYYMMDD>-<用途>/`，不随手乱放

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

## 核心原则（四条）

1. **单一真源**：`data/core/` 只读。要改结果，回源头改数据、重跑程序，**不改产物**。
2. **唯一入口**：`src/main.py` 是唯一可执行入口，参数一律外部传入。
3. **证据说话**：交付必须带 `manifest.md`，验收结论可复现；口头「已完成」不算完成。
4. **外来必入箱**：任何从外部拿到的文件先进 `data/inbox/`，能重现的删、不能重现的转正，**不许散落、不许「先放着」**。

## 角色与职责

| 角色 | 职责 | 明确不做 |
| --- | --- | --- |
| **主理人（Manager）** | 拆解计划、派发任务、验收成果、维护规格与基线规则 | 不独自埋头写业务代码 |
| **Subagent** | 按计划执行单一任务，按格式回报 | 不改计划、不改基线规则、不顺手重构、不发散加戏 |

执行中若发现计划站不住脚：**停下并回报**，不擅自改道。

## 写入权限

| 文件 / 目录 | 主理人 | Subagent |
| --- | --- | --- |
| `README.md` | ✅ 写 | 👁 只读 |
| `AGENTS.md` | ✅ 写 | ✅ **自由写**（Agent 自己的地盘） |
| `docs/specs/项目总方案以及框架.md` | ✅ 写 | 👁 只读 |
| `docs/specs/项目进度.md` | ✅ 追加 | ✅ 追加（严禁改格式） |
| `docs/specs/memory.md` | ✅ 写 | ✅ 追加踩坑（注明来源与会话 ID） |
| `docs/plan/` | ✅ 写 | 👁 只读 |
| `docs/web_search/` | ✅ 写 | ✅ 写自己的检索记录 |
| `src/` | ✅ 写 / 验收 | ✅ 仅限本次任务范围 |
| `data/core/` | ✅ 写（需授权） | 👁 **只读** |
| `data/inbox/` | ✅ 建收件目录 | ✅ 建自己的收件目录，必须带 `_inbox.md` |
| `data/db/` | ✅ 导入 / 变更 schema | ✅ 按 ingest 规范导入 |
| `data/temp/`、`temp_text/` | ✅ 写 | ✅ 写，只删自己建的 |
| `output/` | ✅ 交付 | ✅ 只写自己的交付目录 |
| `log/` | ✅ 追加 | ✅ 追加（按 Agent 分文件） |

## 规则细则

### `项目进度.md` 格式（硬规定）

两级分类：**日期 → 模型 → 编号条目**。每条必须含**完成内容、时间、会话 ID**，四项缺一不可。

```markdown
## YYYY-MM-DD

### <模型名>

1. <完成了什么>
   - 时间：HH:MM
   - 会话 ID：`sess_xxx`
```

- 目标小节存在则**追加**，不存在则新建
- **只追加不覆写**：不改、不删他人条目
- 发现格式错误：上报主理人统一订正，不自行重排

### Subagent 回报格式

任务结束**必须**用这四段回报，缺段视为未完成：

```
1. 完成项：<做了什么>（已写入 项目进度.md：日期 / 模型 / 条目号）
2. 产出物：<文件路径清单>
3. 踩坑：<无 / 现象 → 原因 → 正确做法>（有则已写入 memory.md）
4. 待决策：<无 / 需要主理人或老大拍板的问题>
```

### 命名约定

- 说明类文件统一 `readme.md`（全小写，与现有文件保持一致）
- 业务正文类可用中文名，如 `项目进度.md`、`项目总方案以及框架.md`
- 新增文件名**不得混用大小写**（不要同时出现 `readme.md` 与 `README-xxx.md`）
- 计划文件：`docs/plan/YYYY-MM-DD-<主题>.md`
- 交付目录：`output/YYYY-MM-DD-<主题>/`

## 红线（违反即回滚）

**数据**

- 不修改、不删除 `data/core/` 任何文件
- 不手改 `output/` 里的产物；要改就回源头重跑
- 不把有长期价值的内容只存在 `temp_text/` 或 `data/temp/`
- **外来文件（下载的 Excel / CSV / 压缩包 / PDF）必须先落 `data/inbox/<YYYYMMDD>-<用途>/` 并写 `_inbox.md`**，禁止散落在根目录、`src/`、`temp_text/`
- 收件目录必须写终态（`已入库` / `已转正` / `已清理`），禁止「先放着，以后再说」
- 库中禁止 `DROP` / `TRUNCATE` / 无条件 `DELETE` / `UPDATE`；任何导入必须有 `ingest_log` 记录

**链路**

- 不新增第二个程序入口（`src/main.py` 唯一）
- 不硬编码绝对路径、日期、密钥；密钥走环境变量

**安全 / Git**

- 禁止 `rm -rf`、通配符批量删除
- 禁止未经明确授权的 `git commit` / `push` / `reset --hard` / `clean -fd` / `checkout .`
- 禁止跳过验证就宣称「已完成 / 已通过」

## 收尾必做（每次任务）

- [ ] 追加 `docs/specs/项目进度.md` 条目（含时间与会话 ID）
- [ ] 踩到的坑写入 `docs/specs/memory.md`（场景 → 坑 → 正确做法）
- [ ] 自己的 `data/inbox/` 收件目录已写终态，原始文件按判定表删除或转正
- [ ] 导入库的数据在 `ingest_log` 有记录，行数与来源一致
- [ ] `output/<日期>-<主题>/` 内 `manifest.md` 完整（涉及入库的附 `ingest_log` 快照）
- [ ] 自己产生的临时文件已清理（**只删自己新建的**）
