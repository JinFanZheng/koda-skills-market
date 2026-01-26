---
name: ralph
description: Execute multiple independent tasks using the Ralph Loop pattern. Each task runs with fresh context to avoid token overflow.
---

# Ralph Loop Skill

Ralph 是一种任务执行模式，通过为每个任务创建新的 Agent 上下文来高效完成多个独立任务。

## 何时使用

使用 `ralph_execute` 工具当：

- 用户请求涉及 **3+ 个独立步骤**
- 每个步骤可以 **单独执行和验证**
- 任务之间 **不需要共享上下文**
- 组合工作量可能 **超出上下文窗口**

## 何时不用

- 单一简单任务（直接执行）
- 步骤之间需要共享状态
- 探索性/交互式工作

## 最佳实践

### 拆分大文件任务

**重要**：避免在单个任务中生成大文件（如完整的 HTML 页面 + CSS + JS）。
模型生成过长的内容可能导致 API 响应截断。

**错误示例** - 单任务生成完整前端：
```json
{
  "id": "1",
  "title": "创建完整前端界面",
  "description": "创建包含 HTML、CSS、JavaScript 的完整前端页面",
  "priority": 1
}
```

**正确示例** - 拆分为多个小任务：
```json
[
  {"id": "1", "title": "创建 HTML 结构", "description": "在 ./app/ 创建基础 HTML 结构", "priority": 1},
  {"id": "2", "title": "添加 CSS 样式", "description": "在 ./app/ 添加样式文件", "priority": 2},
  {"id": "3", "title": "添加 JavaScript", "description": "在 ./app/ 添加交互逻辑", "priority": 3},
  {"id": "4", "title": "集成和测试", "description": "确保各部分正确集成", "priority": 4}
]
```

### 每个任务应该是原子性的

- 一个任务创建 1-3 个相关文件
- 每个任务可以独立验证
- 失败时只需重试该任务

## 如何使用

### 1. 分解任务

将用户请求拆分为独立任务，每个任务包含：
- `id`: 唯一标识符
- `title`: 简短描述
- `description`: 详细说明（**必须包含项目目录**）
- `acceptanceCriteria`: 完成条件列表（可选）
- `priority`: 执行顺序（1=最先）

### 2. 指定项目目录

**重要**：第一个任务必须在 `description` 中明确指定项目目录，后续任务也要引用该目录。

```json
{
  "id": "1",
  "title": "创建项目结构",
  "description": "在 ./my-blog/ 目录下创建项目结构...",
  "priority": 1
}
```

这样可以：
- 避免文件散落在工作目录根目录
- 保持项目文件的组织性
- 便于后续任务引用

### 3. 调用工具

```json
{
  "tasks": [
    {
      "id": "1",
      "title": "创建用户模型",
      "description": "创建包含 id, name, email 字段的 User 模型",
      "acceptanceCriteria": ["模型文件存在", "包含必要字段"],
      "priority": 1
    },
    {
      "id": "2",
      "title": "创建用户服务",
      "priority": 2
    }
  ],
  "progressPath": ".ralph/project-progress.json",
  "maxIterations": 50
}
```

## 示例场景

### 创建多个文件

用户: "创建开发、测试、生产三个环境的配置文件"

```json
{
  "tasks": [
    {"id": "dev", "title": "创建 config-dev.json", "priority": 1},
    {"id": "staging", "title": "创建 config-staging.json", "priority": 2},
    {"id": "prod", "title": "创建 config-prod.json", "priority": 3}
  ]
}
```

### 创建完整项目

用户: "创建一个现代化博客网站"

```json
{
  "tasks": [
    {
      "id": "1",
      "title": "创建项目结构",
      "description": "在 ./blog-website/ 目录下创建项目结构，包括 src/、public/、assets/ 目录和 package.json",
      "priority": 1
    },
    {
      "id": "2",
      "title": "开发 HTML 模板",
      "description": "在 ./blog-website/src/ 下创建响应式 HTML 模板",
      "priority": 2
    },
    {
      "id": "3",
      "title": "实现主题切换",
      "description": "在 ./blog-website/ 项目中实现亮色/暗色主题切换功能",
      "priority": 3
    }
  ],
  "progressPath": "blog-progress.json"
}
```

**注意**：每个任务的 `description` 都明确引用了 `./blog-website/` 目录。

## 特性

| 特性 | 说明 |
|------|------|
| **自动重试** | 失败任务自动在后续迭代重试 |
| **进度持久化** | 进度保存到文件，支持中断恢复 |
| **学习传递** | 每次迭代的经验传递给后续任务 |
| **嵌套执行** | 复杂子任务可以进一步使用 Ralph |

## 参数说明

### ralph_execute

| 参数 | 必填 | 说明 |
|------|------|------|
| `tasks` | 是 | 任务列表 |
| `progressPath` | 否 | 进度文件名（相对路径自动放入 Agent ralph 目录） |
| `maxIterations` | 否 | 最大迭代次数（默认 50） |
| `verifyCommands` | 否 | 每个任务后运行的验证命令 |

### ralph_resume

用于检查和恢复未完成的 Ralph 任务：

| 参数 | 必填 | 说明 |
|------|------|------|
| `progressPath` | 否 | 要恢复的进度文件。不指定则列出所有未完成任务 |

**使用流程**：
1. 调用 `ralph_resume` 查看未完成的任务
2. 如果有未完成任务，使用相同的 `progressPath` 调用 `ralph_execute` 继续执行

## 目录结构

Ralph 执行时会创建以下目录结构：

```
.kode/{agentId}/
├── ralph/
│   ├── progress_{GUID}.json          # 进度文件（默认）或 {progressPath}
│   ├── iter1_task1/                  # 任务1子Agent
│   │   ├── meta.json
│   │   └── runtime/
│   ├── iter2_task2/                  # 任务2子Agent
│   │   └── ...
│   └── ...
└── meta.json
```

- **进度文件**: 如果指定相对路径如 `my-progress.json`，会解析为 `.kode/{agentId}/ralph/my-progress.json`
- **子 Agent**: 每个任务创建独立的子 Agent，存放在父 Agent 的 `ralph/` 子目录下
