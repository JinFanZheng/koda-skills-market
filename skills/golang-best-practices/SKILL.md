---
name: golang-best-practices
description: >-
  Golang 企业级开发最佳实践与专家级决策框架。涵盖：代码规范权衡、API设计陷阱、并发避坑、
  性能调优、限流熔断。当用户需要：Go项目架构决策、goroutine泄露排查、channel设计选择、
  context超时控制、性能瓶颈分析、生产级容错时使用此技能。
---

# Golang 最佳实践

## 核心价值

本技能不是 Go 语言教程，而是**专家级决策框架**和**生产环境避坑指南**。

## 快速导航

根据你的问题选择对应章节：

| 问题场景 | 查看章节 |
|---------|---------|
| 代码组织、import 分组、错误处理权衡 | [代码规范与权衡](references/coding-standards.md) |
| RESTful 陷阱、HTTP code 选择、gRPC 选型 | [API 设计决策](references/api-design.md) |
| 分支策略、commit 规范、版本号管理 | [Git 工作流规范](references/git-workflow.md) |
| 设计模式选型、接口设计原则 | [设计模式实战](references/design-patterns.md) |
| goroutine 泄露、channel 关闭、context 传播 | [并发编程避坑](references/concurrency.md) |
| 限流熔断、缓存选型、重试退避 | [生产级效率库](references/efficient-libs.md) |

## 专家思维原则

### 决策优先于语法

Claude 已经知道 Go 语法。本技能聚焦于：
- **什么时候**用什么方案
- **为什么**选择 A 而不是 B
- **有什么**坑和副作用

### 权衡思维

每个决策都有代价：
- Mutex vs Atomic：简单 vs 性能
- Channel vs Mutex：通信 vs 共享
- sync.Pool：减少 GC vs 内存占用

### 避坑第一

生产环境最怕的不是性能差，而是：
- goroutine 泄露
- 死锁
- context 超时不传播
- 限流失效

## 章节加载指南

- **代码规范**: 完整阅读，重点关注权衡分析
- **API 设计**: 根据 RESTful/gRPC 需求选择性阅读
- **Git 工作流**: 规范类，完整阅读
- **设计模式**: 按需查阅特定模式
- **并发编程**: **必读**，特别是 channel 关闭和 context 部分
- **效率库**: 选型时查阅，重点关注熔断和限流
