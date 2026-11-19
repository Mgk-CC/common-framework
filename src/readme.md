# src — 主程序脚本目录

项目**唯一可执行代码**的所在地：把 `data/core/` 的输入，跑成 `output/` 的产物。

本文件只管「代码怎么写、怎么跑」；业务规则见 `docs/specs/`，执行计划见 `docs/plan/`。

## 目录约定

```
src/
├── main.py           # 唯一入口（命令行）
├── config/           # 配置读取与默认值
├── pipeline/         # 业务流程各步骤，一步一个模块
├── utils/            # 通用工具：路径、日志、IO、重试
└── readme.md
```

新增模块先想清楚归属：属于某个业务步骤进 `pipeline/`，通用能力进 `utils/`，别在 `src/` 根目录随手建脚本。

## 入口规范

- **唯一入口**：`src/main.py`。对外只暴露这一种运行方式：

  ```bash
  python -m src.main --input data/core/xxx --out output/2026-11-19-主题
  ```

- **参数一律外部传入**：路径、日期、模式等不许在代码里写死，统一走命令行参数或环境变量。
- **`main.py` 只做三件事**：解析参数 → 打印运行信息 → 按顺序编排 `pipeline/` 里的步骤。业务逻辑不写在入口里。
- **启动即打印**：时间、会话 ID、完整参数、输入路径，写进 `log/`（格式见 `log/readme.md`）。

## 环境与依赖

- 必须使用独立虚拟环境，禁止污染全局环境：

  ```bash
  python -m venv .venv
  source .venv/Scripts/activate      # Windows
  pip install -r requirements.txt
  ```

- 依赖统一记在 `requirements.txt`，固定版本号；`.venv/` 不纳入版本库。
- 只用 **bash** 执行命令，不用 PowerShell / cmd。
- 网络不通时再考虑走代理 `http://127.0.0.1:7897`，不要在脚本里写死代理。

## 代码风格

| 项 | 约定 |
| --- | --- |
| 模块 / 函数 / 变量 | `snake_case` |
| 类 | `PascalCase` |
| 常量 | `UPPER_SNAKE_CASE` |
| 模块说明 | 每个文件顶部一行 docstring：这个模块干什么 |
| 可执行模块 | 必须有 `if __name__ == "__main__":` |
| 路径处理 | 用 `pathlib.Path` 与项目根相对路径，不拼绝对路径字符串 |

## 数据边界（红线）

- **只读** `data/core/`：绝不写入、修改、删除其中的文件。
- **中间结果**写 `data/temp/`，可随时被重建或清理。
- **最终交付**写 `output/<YYYY-MM-DD>-<主题>/`，并在同目录产出 `manifest.md`（见 `output/readme.md`）。
- 数据文件、样本文件、下载文件**不得**放进 `src/`。
- 密钥、token 从环境变量读取，**禁止硬编码**进代码或提交。

## 日志

- 统一写入 `log/`，文件名按 `log/readme.md` 的规范（带日期与会话 ID）。
- 每个关键步骤记 `INFO`，异常记 `ERROR` 并带完整 traceback。
- 不把 `print` 当日志用：面向人的输出可以 print，留证的信息必须进 log。

## 与其它目录的关系

| 目录 | 关系 |
| --- | --- |
| `data/core/` | 上游输入，只读 |
| `data/temp/` | 中间数据，可重建 |
| `output/` | 下游产物，跑完必须落这里 |
| `log/` | 运行轨迹 |
| `temp_text/` | 仅供人工阅读的原始文本，程序不应依赖 |

## 红线

- 不新增第二个入口脚本（出现「临时脚本」的念头 → 做成子命令或进 `pipeline/`）
- 不在代码里写死绝对路径、日期、密钥
- 不手改 `output/` 里的产物：要改就改代码或 `data/core/`，重跑一遍
- 不把调试用的 print / 临时文件留在提交内容里
