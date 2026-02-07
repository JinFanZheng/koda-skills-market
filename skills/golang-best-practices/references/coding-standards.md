# 代码规范与权衡

## 核心原则

### 决策优于教条

代码规范不是死的规则，而是权衡的结果。每个选择都有代价。

---

## 🚨 NEVER List（常见陷阱）

### 1. 绝不使用裸 return

```go
// ❌ WRONG - 难以理解
func foo() (int, error) {
    if err != nil {
        return  // 返回什么？零值？错误？
    }
    return 42, nil
}

// ✅ RIGHT - 显式返回
func foo() (int, error) {
    if err != nil {
        return 0, fmt.Errorf("failed: %w", err)
    }
    return 42, nil
}
```

**WHY**: 裸 return 的返回值不明确，维护困难。

---

### 2. 绝不在公共 API 使用 panic

```go
// ❌ WRONG - panic 会崩溃整个程序
func GetUser(id int) *User {
    if id <= 0 {
        panic("invalid id")  // 不要这样做！
    }
    return fetchUser(id)
}

// ✅ RIGHT - 返回 error
func GetUser(id int) (*User, error) {
    if id <= 0 {
        return nil, fmt.Errorf("invalid id: %d", id)
    }
    return fetchUser(id), nil
}
```

**WHY**: panic 会导致整个程序崩溃，公共 API 应该优雅地返回错误。

---

### 3. 绝不忽略错误返回值

```go
// ❌ WRONG - 忽略错误
file, _ := os.Open("config.txt")  // 如果失败怎么办？

// ✅ RIGHT - 处理错误
file, err := os.Open("config.txt")
if err != nil {
    log.Fatalf("cannot open config: %v", err)
}
```

**WHY**: 忽略错误会导致静默失败，后续操作会出更难追踪的问题。

---

### 4. 绝不使用全局可变状态

```go
// ❌ WRONG - 全局状态
var db *sql.DB

func InitDB() {
    db = sql.Open(...)  // 多次初始化会覆盖
}

// ✅ RIGHT - 依赖注入
type Service struct {
    db *sql.DB
}

func NewService(db *sql.DB) *Service {
    return &Service{db: db}
}
```

**WHY**: 全局状态使测试困难，并发不安全，难以追踪状态变化。

---

## 结构体设计权衡

### 字段顺序：嵌入字段放前面

```go
// ❌ WRONG - 字段顺序混乱
type Client struct {
    version int
    http.Client
}

// ✅ RIGHT - 嵌入字段在前
type Client struct {
    http.Client
    version int
}
```

**WHY**: Go 的规范是嵌入字段（未命名的字段）放在前面，提高可读性。

---

### 接收器选择：值 vs 指针

```
需要修改接收器？ → 用指针接收器
   ├─ 大结构体（避免复制） → 用指针接收器
   └─ 小结构体（< 16 字节） → 用值接收器

一致性优先？ → 统一用指针接收器（最常见）
```

| 场景 | 接收器类型 | 原因 |
|------|-----------|------|
| 修改结构体 | `*T` | 必须用指针才能修改 |
| 大结构体（> 16 字节） | `*T` | 避免复制开销 |
| 小结构体，只读 | `T` | 值语义，不可变 |
| 需要满足 interface | `T` 或 `*T` | 看 interface 要求 |

---

## Import 分组决策

### 分组规则

```go
import (
    // 1. 标准库
    "context"
    "net/http"
    
    // 2. 第三方库
    "github.com/gin-gonic/gin"
    "go.uber.org/zap"
    
    // 3. 内部包
    "git.xiaorui.cc/ocean/jellyfish/internal/api"
    "git.xiaorui.cc/ocean/jellyfish/pkg/log"
)
```

**WHY**: 分组提高可读性，IDE 也支持分组自动整理。

### 未使用 import 自动清理

```bash
goimports -w .  # 自动排序和删除未使用的 import
```

---

## 错误处理权衡

### 错误包装 vs 原始错误

```go
// 方案 1: 保留原始错误
func ReadConfig(path string) ([]byte, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, err  // 直接返回原始错误
    }
    return data, nil
}

// 方案 2: 包装错误（添加上下文）
func ReadConfig(path string) ([]byte, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("read config %s: %w", path, err)
    }
    return data, nil
}
```

**决策树**:
```
错误需要添加上下文？ → 用 fmt.Errorf 包装
   └─ 否 → 直接返回原始错误

调用方需要判断错误类型？ → 用 errors.As
   └─ 否 → 用 errors.Is
```

### early return vs if-else 嵌套

```go
// ❌ WRONG - 嵌套过深
func process() error {
    if user != nil {
        if user.IsValid() {
            if db != nil {
                return db.Save(user)
            }
        }
    }
    return nil
}

// ✅ RIGHT - early return
func process() error {
    if user == nil {
        return nil
    }
    if !user.IsValid() {
        return nil
    }
    if db == nil {
        return nil
    }
    return db.Save(user)
}
```

**原则**: 快速失败，减少嵌套。

---

## 单例模式权衡

### 饿汉 vs 懒汉

```go
// 方案 1: 饿汉（简单但启动慢）
var instance = &Singleton{}

func GetInstance() *Singleton {
    return instance
}

// 方案 2: 懒汉（启动快但需处理并发）
var (
    instance *Singleton
    once     sync.Once
)

func GetInstance() *Singleton {
    once.Do(func() {
        instance = &Singleton{}
    })
    return instance
}
```

**权衡**:
- 饿汉：简单，但启动时初始化所有单例，可能浪费资源
- 懒汉：按需初始化，但需要 sync.Once 处理并发

**推荐**: 懒汉模式（使用 sync.Once）

---

## 常量定义决策

### iota 使用场景

```go
// ✅ GOOD - 有序的枚举
const (
    ModeAdd     = iota + 1  // 1
    ModeDel                 // 2
    ModeUpdate              // 3
    ModeUpsert              // 4
)

// ❌ BAD - 无序的值不适合 iota
const (
    StatusPending = 1
    StatusActive  = 3  // 跳过了 2
    StatusBlocked = 5  // 跳过了 4
)
```

**决策树**:
```
值是连续的？ → 用 iota
   └─ 否 → 显式定义每个值
```

---

## Defer 使用权衡

### Defer 性能考虑

```go
// Go 1.14 之前：defer 有开销（~40ns）
func foo() {
    mu.Lock()
    defer mu.Unlock()  // 热路径可能有性能影响
    // ...
}

// Go 1.14+：defer 被优化，开销大幅降低
// 大多数场景可以放心使用
```

**权衡**:
- **好处**: 保证资源释放，避免忘记
- **代价**: 微小的性能开销（Go 1.14+ 可忽略）

**推荐**: 除非在极热路径上，否则始终用 defer

---

## 接口设计原则

### 小接口 vs 大接口

```go
// ❌ WRONG - 大接口（违反接口隔离原则）
type UserInterface interface {
    Create() error
    Read() error
    Update() error
    Delete() error
    List() error
    Validate() error
    Serialize() error
    // ... 20+ 方法
}

// ✅ RIGHT - 小接口（单一职责）
type Reader interface {
    Read(id string) (*User, error)
}

type Writer interface {
    Create(user *User) error
    Update(user *User) error
}

type Validator interface {
    Validate(user *User) error
}
```

**原则**: 接口应该小而专注。大接口难以实现和测试。

### 接口合理性检查

```go
type Handler struct{}

// 编译期检查：Handler 是否实现了 http.Handler
var _ http.Handler = (*Handler)(nil)

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    // ...
}
```

**WHY**: 如果 Handler 没有实现所有方法，编译期就会报错，而不是运行时才发现。

---

## 选项模式（Options Pattern）

### 使用场景

```
配置参数很多（> 5 个）？ → 用选项模式
   └─ 否 → 直接用参数
```

```go
// ❌ WRONG - 参数太多
func NewServer(host string, port int, timeout time.Duration, 
               maxConn int, tlsConfig *tls.Config, 
               logger *zap.Logger, metrics *Metrics) *Server {
    // ...
}

// ✅ RIGHT - 选项模式
type Option func(*Server)

func WithTimeout(timeout time.Duration) Option {
    return func(s *Server) {
        s.timeout = timeout
    }
}

func WithLogger(logger *zap.Logger) Option {
    return func(s *Server) {
        s.logger = logger
    }
}

func NewServer(opts ...Option) *Server {
    s := &Server{
        timeout: 30 * time.Second,
        logger:  zap.NewNop(),
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// 使用
server := NewServer(
    WithTimeout(60*time.Second),
    WithLogger(logger),
)
```

**优点**:
- 可扩展：添加新选项不影响现有代码
- 可读：调用时明确看到配置了什么
- 有默认值：不需要每个参数都提供

---

## 命名规范

### Bool 命名

```go
// ✅ GOOD - 使用判断性动词
isDone
hasError
canManage
shouldRetry

// ❌ BAD - 名词形式
done
error
manage
retry
```

**原则**: Bool 变量名用 `is/has/can/should` 等判断性前缀。

---

## 项目结构决策

### 标准结构 vs DDD

```
简单项目？ → 标准结构（Standard Go Project Layout）
   ├─ cmd/        - 入口
   ├─ internal/   - 私有代码
   ├─ pkg/        - 公共库
   └─ api/        - API 定义

复杂领域？ → DDD（Domain-Driven Design）
   ├─ domain/     - 领域模型
   ├─ application/ - 应用服务
   ├─ infrastructure/ - 基础设施
   └─ interfaces/ - 接口层
```

**重要**: 不要过度纠结结构，"适合自己就好，一眼能看明白就好"。

---

## 测试策略

### Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive", 1, 2, 3},
        {"negative", -1, -2, -3},
        {"zero", 0, 0, 0},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d, want %d", 
                    tt.a, tt.b, result, tt.expected)
            }
        })
    }
}
```

**优点**: 易于添加新测试用例，每个用例独立运行。

---

## Makefile 最佳实践

```makefile
.PHONY: build test lint clean

# 默认目标
all: build

# 构建
build:
	@echo "Building..."
	go build -o bin/app cmd/main.go

# 测试
test:
	@echo "Running tests..."
	go test -v -race -cover ./...

# 代码检查
lint:
	@echo "Linting..."
	golangci-lint run

# 清理
clean:
	@echo "Cleaning..."
	rm -rf bin/

# 格式化
fmt:
	@echo "Formatting..."
	go fmt ./...
```

**原则**: 统一执行入口，所有操作收敛在 Makefile 里。

---

## Tips（快速参考）

- ✅ 用 `goimports` 自动整理 import
- ✅ 用 `golangci-lint` 做静态检查
- ✅ 早期返回，减少嵌套
- ✅ 错误要包装，保留原始错误
- ✅ 接口要小，大接口拆分
- ❌ 不要用全局变量
- ❌ 不要在公共 API panic
- ❌ 不要忽略错误
