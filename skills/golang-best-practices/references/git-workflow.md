# Git 工作流与版本管理

## 核心原则

Git 历史是团队协作的记录，清晰的提交历史能提高代码审查效率和问题追踪速度。

---

## 🚨 NEVER List（常见陷阱）

### 1. 绝不在公共分支做 reset

```bash
# ❌ WRONG - 会丢失其他人的提交
git reset --hard HEAD~3  # 在 master 分支上

# ✅ RIGHT - 用 revert
git revert HEAD~3  # 创建新提交撤销变更
```

**WHY**: reset 会重写历史，公共分支的其他人会遇到冲突。revert 创建新提交，安全。

---

### 2. 绝不在公共分支做 rebase

```bash
# ❌ WRONG - 重写公共历史
git rebase master  # 在 feature 分支被其他人合并后

# ✅ RIGHT - 用 merge
git merge master
```

**WHY**: rebase 会改变提交历史，已经 push 到远程的分支不要 rebase。

---

### 3. 绝不提交大文件

```bash
# ❌ WRONG - 提交了大文件（> 5MB）
git add large-dataset.zip
git commit -m "Add dataset"

# ✅ RIGHT - 用 Git LFS 或外部存储
git lfs track "*.zip"
git add large-dataset.zip
git commit -m "Add dataset with LFS"
```

**WHY**: 大文件会让仓库体积膨胀，克隆和拉取变慢。删除也很困难。

---

### 4. 绝不包含敏感信息

```bash
# ❌ WRONG - 提交了密码/密钥
git add config.toml  # 包含数据库密码
git commit -m "Add config"

# ✅ RIGHT - 用环境变量或密钥管理
git add config.example.toml  # 示例配置
git commit -m "Add config template"
```

**WHY**: 一旦提交到 Git，即使删除也能在历史中找到。用 `.gitignore` 防止。

---

## 分支模型选择

### Git Flow（完整但复杂）

```
master    - 生产环境代码，只能从 release/hotfix 合并
develop   - 开发主分支
feature/* - 功能分支，从 develop 分支
release/* - 发布分支，从 develop 分支
hotfix/*  - 热修复分支，从 master 分支
```

**适用**: 有明确发布周期、需要维护多版本的项目。

---

### Simplified Git Flow（推荐）

```
master    - 生产环境
develop   - 开发环境
feature/* - 功能分支
hotfix/*  - 紧急修复
```

**适用**: 大多数项目，简化了 Git Flow。

---

### GitHub Flow（最简单）

```
main      - 生产环境
feature/* - 功能分支，通过 Pull Request 合并
```

**适用**: 持续部署、每次提交都可部署的项目。

---

## Commit 规范

### 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

| Type | 含义 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(auth): add OAuth2 login` |
| `fix` | 修复 bug | `fix(api): handle nil pointer in user fetch` |
| `docs` | 文档 | `docs(readme): update installation steps` |
| `style` | 格式（不影响功能） | `style: fix indentation` |
| `refactor` | 重构 | `refactor(service): extract validation logic` |
| `perf` | 性能优化 | `perf(query): add database index` |
| `test` | 测试 | `test(user): add integration tests` |
| `chore` | 构建/工具 | `chore: upgrade dependencies` |

### Scope 范围

Scope 应该是模块名或功能区域：
- `auth` - 认证模块
- `api` - API 层
- `database` - 数据库
- `ui` - 用户界面
- `user` - 用户功能

### Subject 原则

- 用祈使句（"add" 不是 "added"）
- 首字母小写
- 不要用句号结尾
- 限制在 50 字符内

---

## Rebase vs Merge

### 何时用 Rebase

```bash
# 下游分支更新上游内容 → 用 rebase
git checkout feature
git rebase develop  # 保持线性历史
```

**优点**: 历史清晰，避免不必要的 merge commit

---

### 何时用 Merge

```bash
# 上游分支合并下游分支 → 用 merge
git checkout develop
git merge feature  # 保留完整历史
```

**优点**: 保留真实的分支结构，便于查看功能开发历史

---

### 推荐工作流

```
1. 创建功能分支
   git checkout -b feature/add-login develop

2. 开发过程中定期同步上游
   git checkout feature/add-login
   git rebase develop  # 保持最新

3. 完成后合并回上游
   git checkout develop
   git merge feature/add-login  # 用 merge 保留历史
```

---

## 版本号规范（Semver）

### 格式

```
主版本号.次版本号.修订号-预发布标签
如: 2.1.3-beta.1
```

### 规则

| 变更类型 | 版本变化 | 示例 |
|---------|---------|------|
| 不兼容的 API 修改 | 主版本号+1 | 1.2.3 → 2.0.0 |
| 向下兼容的功能新增 | 次版本号+1 | 1.2.3 → 1.3.0 |
| 向下兼容的问题修正 | 修订号+1 | 1.2.3 → 1.2.4 |

### 预发布标签

| 标签 | 含义 | 示例 |
|------|------|------|
| `alpha` | 内部测试版 | 1.0.0-alpha.1 |
| `beta` | 公开测试版 | 1.0.0-beta.1 |
| `rc` | 候选版本（不再加新功能） | 1.0.0-rc.1 |
| (无标签) | 正式版 | 1.0.0 |

---

## 合并多个 Commit

### 场景：提交记录太散

```bash
# 方法 1: Merge squash（在上游分支）
git checkout develop
git merge --squash feature-branch
git commit -m "feat: add complete feature"

# 方法 2: Rebase interactive（在下游分支）
git checkout feature-branch
git rebase -i HEAD~5  # 合并最近 5 个提交
```

**推荐**: 功能分支合并前用 squash，保持主分支历史干净。

---

## 实用技巧

### 撤销操作

| 操作 | 命令 | 说明 |
|------|------|------|
| 撤销最后一次提交（保留修改） | `git reset --soft HEAD~1` | 提交回退，修改在工作区 |
| 撤销最后一次提交（丢弃修改） | `git reset --hard HEAD~1` | 完全回退 |
| 修改最后一次提交 | `git commit --amend` | 修改提交内容或消息 |
| 撤销已 push 的提交 | `git revert` | 创建新提交撤销变更 |

### 查看历史

```bash
git log --oneline --graph --all  # 图形化显示
git reflog                      # 查看所有操作记录（包括 reset）
git log -p -2                   # 查看最近 2 次提交的 diff
```

### 清理

```bash
git clean -fd   # 删除未跟踪的文件和目录
git gc          # 垃圾回收，减小仓库体积
```

---

## Hook 自动化

### 推荐 Hook

| Hook | 用途 | 工具 |
|------|------|------|
| `pre-commit` | 代码格式化、静态检查 | `pre-commit`, `golangci-lint` |
| `commit-msg` | 检查 commit 格式 | `commitlint` |
| `pre-push` | 运行测试 | `go test` |

### 示例：pre-commit

```bash
#!/bin/sh
# .git/hooks/pre-commit

# 格式化代码
go fmt ./...

# 静态检查
golangci-lint run

# 运行测试
go test ./...
```

---

## Tips（快速参考）

- ✅ 公共分支用 merge/revert，不用 reset/rebase
- ✅ commit 信息用规范格式：`type(scope): subject`
- ✅ 版本号遵循 Semver：主.次.修订
- ✅ 用 `.gitignore` 防止提交大文件和敏感信息
- ✅ `git pull --rebase` 保持线性历史
- ✅ `git stash` 随意切换分支
- ✅ `git reflog` 恢复误操作
- ❌ 不要在公共分支 reset
- ❌ 不要在公共分支 rebase
- ❌ 不要提交大文件或敏感信息
