# memory — 踩坑记录与固化记忆

> 只记录**可复用**的经验，不记流水账（流水账归 `项目进度.md`）。
> 形态是「记忆」：下次遇到同类场景，读完这一条就能直接避开。

## 写法（三段式，缺一段就不算记完）

| 段 | 写什么 | 反例 |
| --- | --- | --- |
| 触发场景 | 什么情况下会遇到（可检索的关键词） | 「跑脚本报错」 |
| 踩到的坑 | 现象 + 根因 | 「不知道为啥失败」 |
| 正确做法 | 可直接照做的结论 / 命令 | 「以后注意点」 |

模板：

```markdown
### <一句话标题：现象概括>

- 场景：<什么时候会遇到>
- 现象：<报什么错 / 表现如何>
- 根因：<为什么>
- 结论：<以后怎么做，给可执行的命令或规则>
- 记录：2026-11-19　<主理人 / Agent 名>　会话 ID：`sess_xxx`
```

## 分类

### 环境与工具

#### rg 巡检收件箱永远显示「干净」

- 场景：用 `rg` 巡检 `data/inbox/` 下有没有未收尾的 `_inbox.md`
- 现象：明明放着未收尾目录，命令却什么都不输出，误以为收件箱很干净
- 根因：两个坑叠加 —— ① **rg 默认遵守 `.gitignore`**，而 `.gitignore` 里 `data/inbox/*` 被忽略，rg 直接跳过这些文件；② **`-L` 在 ripgrep 里是 `--follow`**（跟随符号链接），不是 grep 的 `--files-without-match`
- 结论：巡检命令固定写成
  `rg --files-without-match --no-ignore-vcs "状态：已" data/inbox -g "_inbox.md"`
  退出码 `0` = 有未收尾目录（会打印路径），`1` = 全部已收尾（干净）
- 记录：2026-11-19　deepseek-v4.1-flash　会话 ID：`01a1f267-1cea-7418-aea5-245500bc0cdb`

#### Windows 下激活虚拟环境路径不同

- 场景：在 Windows 上按 Linux 教程激活 `.venv`
- 现象：`source .venv/bin/activate` 报 `No such file or directory`
- 根因：Windows 的 venv 脚本目录是 `Scripts/` 而非 `bin/`
- 结论：Windows 用 `source .venv/Scripts/activate`；命令统一走 bash
- 记录：2026-11-19　deepseek-v4.1-flash　会话 ID：`01a1f267-1cea-7418-aea5-245500bc0cdb`

### 业务规则

<!-- 数据含义、边界条件、甲方口径等 -->

### 协作流程

<!-- 主理人与 subagent 交接、并发写入、文件冲突等 -->
