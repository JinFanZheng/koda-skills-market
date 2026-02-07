# 设计模式实战与权衡

## 核心原则

设计模式是**工具**，不是目标。选择模式时要考虑：复杂度、可测试性、性能。

---

## 单例模式

### 实现方式选择

```
需要懒加载？ → sync.Once（推荐）
   └─ 启动时初始化可接受？ → 直接用全局变量

需要并发安全？ → sync.Once 或双重检查锁
   └─ 不需要并发？ → 简单懒加载
```

### sync.Once 实现（推荐）

```go
var (
    instance *Database
    once     sync.Once
)

func GetDatabase() *Database {
    once.Do(func() {
        instance = &Database{
            conn: connect(),
        }
    })
    return instance
}
```

**优点**: 线程安全、懒加载、简洁

**缺点**: 测试时无法重置（需要额外支持）

---

### 饿汉式

```go
var instance = &Database{conn: connect()}

func GetDatabase() *Database {
    return instance
}
```

**优点**: 简单、线程安全
**缺点**: 启动时初始化所有单例，可能浪费资源

---

## 工厂模式

### 简单工厂

```go
type Animal interface {
    Speak() string
}

type Dog struct{}
func (d *Dog) Speak() string { return "Woof!" }

type Cat struct{}
func (c *Cat) Speak() string { return "Meow!" }

// 工厂函数
func NewAnimal(animalType string) Animal {
    switch animalType {
    case "dog":
        return &Dog{}
    case "cat":
        return &Cat{}
    default:
        return nil
    }
}
```

**适用**: 类型少、确定不会频繁增加

---

### 工厂方法模式

```go
type AnimalFactory interface {
    CreateAnimal() Animal
}

type DogFactory struct{}
func (df *DogFactory) CreateAnimal() Animal {
    return &Dog{}
}

// 使用
func GetAnimal(factory AnimalFactory) Animal {
    return factory.CreateAnimal()
}
```

**适用**: 需要扩展类型、不修改现有代码

---

## 选项模式（Options Pattern）

### 使用场景

```
配置参数 > 5 个？ → 用选项模式
   └─ 参数可选且有多数默认值？ → 用选项模式

参数 < 5 个？ → 直接用函数参数
```

### 实现

```go
type Option func(*Server)

func WithPort(port int) Option {
    return func(s *Server) {
        s.port = port
    }
}

func WithTimeout(timeout time.Duration) Option {
    return func(s *Server) {
        s.timeout = timeout
    }
}

func NewServer(opts ...Option) *Server {
    s := &Server{
        port:    8080,          // 默认值
        timeout: 30 * time.Second,
    }
    for _, opt := range opts {
        opt(s)
    }
    return s
}

// 使用
server := NewServer(
    WithPort(9090),
    WithTimeout(60*time.Second),
)
```

**优点**:
- 可扩展：添加新选项不影响现有代码
- 可读：调用时明确看到配置
- 默认值：不需要每个参数都提供

**缺点**: 增加代码复杂度

---

## 建设者模式（Builder Pattern）

### 使用场景

```
构建复杂对象？ → 用 Builder
   └─ 对象有很多可选参数？ → 用 Builder

简单对象？ → 直接构造或选项模式
```

### 实现

```go
type Builder interface {
    SetPartA(string) Builder
    SetPartB(string) Builder
    Build() Product
}

type ConcreteBuilder struct {
    partA string
    partB string
}

func (b *ConcreteBuilder) SetPartA(a string) Builder {
    b.partA = a
    return b
}

func (b *ConcreteBuilder) SetPartB(b string) Builder {
    b.partB = b
    return b
}

func (b *ConcreteBuilder) Build() Product {
    return Product{A: b.partA, B: b.partB}
}

// 使用
builder := &ConcreteBuilder{}
product := builder.
    SetPartA("A").
    SetPartB("B").
    Build()
```

**优点**: 链式调用，可读性好
**缺点**: 增加代码量

---

## 面向接口编程

### 为什么用接口

```go
// ❌ WRONG - 依赖具体实现
type Service struct {
    db *MySQLDatabase  // 紧耦合
}

// ✅ RIGHT - 依赖接口
type Service struct {
    db Database  // 松耦合
}

type Database interface {
    Query(sql string) ([]Row, error)
}
```

**优点**:
- **解耦**: 不依赖具体实现
- **可测试**: 可以用 Mock 替换
- **可扩展**: 轻松替换实现

---

### 接口大小原则

```go
// ❌ WRONG - 大接口（违反接口隔离）
type UserInterface interface {
    Create() error
    Read() error
    Update() error
    Delete() error
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

**原则**: 接口应该小而专注

---

### 编译期接口检查

```go
type Handler struct{}

// 编译期检查：Handler 是否实现了 http.Handler
var _ http.Handler = (*Handler)(nil)

func (h *Handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    // ...
}
```

**WHY**: 如果 Handler 没有实现所有方法，编译期就会报错。

---

## 依赖注入

### 构造函数注入（推荐）

```go
type UserService struct {
    db    Database
    cache Cache
    logger Logger
}

func NewUserService(db Database, cache Cache, logger Logger) *UserService {
    return &UserService{
        db:    db,
        cache: cache,
        logger: logger,
    }
}
```

**优点**: 依赖明确、易于测试

---

### 接口注入

```go
type Config interface {
    Get(key string) string
}

type Service struct {
    config Config
}

func NewService(config Config) *Service {
    return &Service{config: config}
}
```

**适用**: 依赖是接口、需要多种实现

---

## 策略模式

### 使用场景

```
多种算法可互换？ → 策略模式
   └─ 运行时选择算法？ → 策略模式
```

### 实现

```go
type CompressionStrategy interface {
    Compress(data []byte) ([]byte, error)
}

type GzipCompression struct{}
func (g *GzipCompression) Compress(data []byte) ([]byte, error) {
    // gzip 实现
}

type ZlibCompression struct{}
func (z *ZlibCompression) Compress(data []byte) ([]byte, error) {
    // zlib 实现
}

// 使用
func CompressData(data []byte, strategy CompressionStrategy) ([]byte, error) {
    return strategy.Compress(data)
}
```

**优点**: 算法可互换、易于扩展

---

## 观察者模式

### 实现（使用 channel）

```go
type EventBus struct {
    subscribers map[string][]chan<- Event
    mu          sync.RWMutex
}

func (eb *EventBus) Subscribe(eventType string) <-chan Event {
    ch := make(chan Event, 100)
    eb.mu.Lock()
    eb.subscribers[eventType] = append(eb.subscribers[eventType], ch)
    eb.mu.Unlock()
    return ch
}

func (eb *EventBus) Publish(event Event) {
    eb.mu.RLock()
    defer eb.mu.RUnlock()
    
    for _, ch := range eb.subscribers[event.Type] {
        select {
        case ch <- event:
        default:
            // channel 满，丢弃
        }
    }
}
```

**适用**: 事件驱动架构、消息总线

---

## 🚨 NEVER List

### 1. 绝不为了模式而模式

```go
// ❌ WRONG - 简单场景用复杂模式
type DogFactory struct{}  // 只有一种 Dog
func (df *DogFactory) CreateDog() *Dog {
    return &Dog{}
}

// ✅ RIGHT - 直接返回
func NewDog() *Dog {
    return &Dog{}
}
```

---

### 2. 绝不创建不必要的接口

```go
// ❌ WRONG - 只有一个实现
type UserInterface interface {
    Save(user *User) error
}

type UserService struct{}

// ✅ RIGHT - 直接用具体类型
type UserService struct{}
func (s *UserService) Save(user *User) error {
    // ...
}
```

**WHY**: 接口是为了解耦和扩展，只有一个实现时不需要接口。

---

## Tips（快速参考）

- ✅ 单例用 sync.Once
- ✅ 参数多用选项模式
- ✅ 依赖接口而非具体实现
- ✅ 接口要小，大接口拆分
- ✅ 策略模式用于可互换的算法
- ❌ 不要为了模式而模式
- ❌ 不要创建不必要的接口
