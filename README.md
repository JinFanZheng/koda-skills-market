# Koda Skills Market

> **Koda 技能市场** - 为 Claude Code 提供的专业技能集合，涵盖旅行规划、数据处理、生活服务和生产力工具。

## 什么是 Skills？

Skills 是包含指令、脚本和资源的文件夹，Claude 可以动态加载它们以在专门任务上提高性能。Skills 教 Claude 如何以可重复的方式完成特定任务，无论是使用公司品牌指南创建文档、使用组织特定工作流程分析数据，还是自动化个人任务。

了解更多信息：
- [什么是 skills？](https://support.claude.com/en/articles/12512176-what-are-skills)
- [在 Claude 中使用 skills](https://support.claude.com/en/articles/12512180-using-skills-in-claude)
- [如何创建自定义 skills](https://support.claude.com/en/articles/12512198-creating-custom-skills)

## 关于本项目

本仓库包含 Koda Skills Market 的专业技能集合，重点关注：

- **旅行与交通**：通勤规划、航班预订、酒店预订、铁路出行、行程规划
- **数据处理**：数据分析、数据库操作、文件处理、数据可视化
- **生活服务**：美食推荐、天气查询、新闻检索、邮件管理
- **生产力工具**：知识管理、记忆操作、信息验证、外汇汇率

每个技能都在各自的文件夹中自包含，包含 `SKILL.md` 文件，其中包含 Claude 使用的指令和元数据。

## 技能列表

### 旅行与交通 (Travel Skills)
| 技能 | 描述 |
|------|------|
| [commute](./skills/commute) | 通勤方案/路线规划（点到点或多点串联） |
| [flight](./skills/flight) | 航班查询与预订管理 |
| [hotel](./skills/hotel) | 酒店搜索与预订 |
| [rail](./skills/rail) | 铁路交通查询 |
| [itinerary](./skills/itinerary) | 旅行行程规划 |

### 数据处理 (Data Skills)
| 技能 | 描述 |
|------|------|
| [data-analysis](./skills/data-analysis) | 数据分析与统计 |
| [data-base](./skills/data-base) | 数据库操作 |
| [data-files](./skills/data-files) | 文件数据处理 |
| [data-viz](./skills/data-viz) | 数据可视化 |

### 生活服务 (Daily Life Skills)
| 技能 | 描述 |
|------|------|
| [food](./skills/food) | 美食与餐厅推荐 |
| [weather](./skills/weather) | 天气信息查询 |
| [news](./skills/news) | 新闻检索与摘要 |
| [email](./skills/email) | 邮件操作与管理 |

### 生产力工具 (Productivity Skills)
| 技能 | 描述 |
|------|------|
| [knowledge](./skills/knowledge) | 知识管理 |
| [memory](./skills/memory) | 记忆管理 |
| [verify](./skills/verify) | 信息验证 |
| [fx](./skills/fx) | 外汇汇率查询 |
| [ralph](./skills/ralph) | Ralph 专用技能 |

## 在 Claude Code 中使用

### 安装技能市场

在 Claude Code 中运行以下命令注册本仓库为插件市场：

```bash
/plugin marketplace add file:///Users/vanzheng/projects/ai-agent/koda-skills-market
```

### 安装技能插件

安装特定技能集：

```bash
# 旅行与交通技能
/plugin install travel-skills@koda-skills-market

# 数据处理技能
/plugin install data-skills@koda-skills-market

# 生活服务技能
/plugin install daily-life-skills@koda-skills-market

# 生产力工具技能
/plugin install productivity-skills@koda-skills-market
```

安装后，您可以直接使用这些技能。例如，安装 `travel-skills` 后，您可以询问：

> "帮我规划从北京到上海的通勤方案"

## 项目结构

```
koda-skills-market/
├── .claude-plugin/
│   └── marketplace.json       # 技能市场配置文件
├── skills/                     # 技能目录
│   ├── commute/
│   │   ├── SKILL.md           # 技能定义文件
│   │   └── references/        # 参考资料目录
│   ├── data-analysis/
│   ├── flight/
│   └── ...
└── README.md
```

## 创建自定义技能

每个技能都是一个包含 `SKILL.md` 文件的文件夹。以下是基本模板：

```markdown
---
name: my-skill-name
description: 对此技能功能的清晰描述以及何时使用它
---

# 我的技能名称

[在此添加 Claude 在此技能激活时将遵循的指令]

## 示例
- 示例用法 1
- 示例用法 2

## 指南
- 指南 1
- 指南 2
```

Frontmatter 需要两个必填字段：
- `name` - 技能的唯一标识符（小写，空格用连字符）
- `description` - 对技能功能和使用时机的完整描述

## 许可证

本项目遵循 Apache 2.0 许可证开源。详见 [LICENSE](./LICENSE) 文件。

## 贡献

欢迎提交 Issue 和 Pull Request！

## 联系方式

- 项目维护者：Koda Skills Market
- 邮箱：admin@koda.ai
