# 生产级效率库选型与使用

## 核心原则

生产环境不是"能用就行"，而是"可靠、可观测、可降级"。

---

## 限流（Rate Limiting）

### 算法选择

```
需要允许突发流量？ → 令牌桶（Token Bucket）
   └─ 恒定速率输出？ → 漏桶（Leaky Bucket）
```

### 令牌桶（推荐）

```go
import "golang.org/x/time/rate"

// 创建：每秒 100 个请求，最大突发 200
limiter := rate.NewLimiter(100, 200)

// 等待
limiter.Wait(ctx)

// 或判断
if !limiter.Allow() {
    return ErrRateLimit
}
```

**优点**: 允许突发、实现简单
**库**: `golang.org/x/time/rate`

---

### 漏桶

```go
import "github.com/uber-go/ratelimit"

// 创建：每秒 100 个请求
limiter := ratelimit.New(100)

// 使用（阻塞）
limiter.Take()
```

**优点**: 恒定输出、平滑流量
**库**: `github.com/uber-go/ratelimit`

---

## 熔断器（Circuit Breaker）

### 状态机

```
Close → 失败率超阈值 → Open
Open → 超时窗口 → Half-Open
Half-Open → 成功 → Close
Half-Open → 失败 → Open
```

### 使用（推荐库）

```go
import "github.com/sony/gobreaker"

cb := gobreaker.NewCircuitBreaker(gobreaker.Settings{
    Name:        "API",
    MaxRequests: 3,                    // Half-Open 状态最多 3 个请求
    Interval:    10 * time.Second,     // 统计周期
    Timeout:     30 * time.Second,     // Open 状态超时
    ReadyToTrip: func(counts gobreaker.Counts) bool {
        return counts.ConsecutiveFailures > 5  // 连续 5 次失败熔断
    },
})

// 使用
result, err := cb.Execute(func() (interface{}, error) {
    return callAPI()
})
```

**配置要点**:
- `MaxRequests`: Half-Open 状态的试探请求数
- `Interval`: 统计失败率的周期
- `Timeout`: Open 状态多久后尝试恢复
- `ReadyToTrip`: 触发熔断的条件

**推荐库**:
- `github.com/sony/gobreaker`（稳定）
- `github.com/rfyiamcool/easybreaker`（简单）

---

## 缓存（Cache）

### 缓存类型选择

```
读多写少？ → sync.Map 或缓存库
   └─ 缓存大对象？ → BigCache/FastCache

需要过期淘汰？ → ccache/ristretto
   └─ 内存紧张？ → freecache
```

### sync.Map

```go
var cache sync.Map

cache.Store("key", value)
if val, ok := cache.Load("key"); ok {
    // 使用 val
}
```

**适用**: 读多写少、缓存命中率高
**不适用**: 写多、需要过期淘汰

---

### ccache（推荐）

```go
import "github.com/karlseguin/ccache"

cache := ccache.New(ccache.Configure().MaxSize(1000))

// 设置（5秒过期）
cache.Set("key", value, time.Second*5)

// 获取
item := cache.Get("key")
if item != nil {
    value := item.Value()
}
```

**优点**: 过期淘汰、LRU、高性能
**适用**: 通用缓存场景

---

### BigCache（大对象）

```go
import "github.com/allegro/bigcache"

cache, _ := bigcache.NewBigCache(bigcache.DefaultConfig(10 * time.Minute))

cache.Set("key", []byte("value"))
val, err := cache.Get("key")
```

**优点**: 内存占用低、支持大对象
**适用**: 缓存大量数据

---

### Ristretto（推荐）

```go
import "github.com/dgraph-io/ristretto"

cache, _ := ristretto.NewCache(&ristretto.Config{
    NumCounters: 1e7,     // 跟踪频率的 key 数量
    MaxCost:     1 << 30,  // 最大缓存大小（字节）
    BufferItems: 64,
})

cache.Set("key", value, 1)
if value, ok := cache.Get("key"); ok {
    // 使用
}
```

**优点**: 基于 TinyLFU、抗缓存污染
**适用**: 高并发、热点数据

---

## 协程池（Goroutine Pool）

### 使用场景

```
需要限制并发数？ → 协程池
   └─ 避免创建过多 goroutine？ → 协程池

任务量可控？ → 直接用 goroutine
```

### 使用（ants）

```go
import "github.com/panjf2000/ants/v2"

pool, _ := ants.NewPool(100)  // 最多 100 个 worker
defer pool.Release()

for _, task := range tasks {
    task := task
    pool.Submit(func() {
        process(task)
    })
}
```

**优点**: 限制并发、避免 goroutine 爆炸
**缺点**: 增加复杂度

**推荐库**: `github.com/panjf2000/ants/v2`

---

## 重试（Retry）

### 指数退避

```
重试间隔 = base_interval * (2 ^ attempt)
```

### 使用

```go
import "github.com/avast/retry-go"

err := retry.Do(
    func() error {
        return callAPI()
    },
    retry.Delay(time.Second),
    retry.Attempts(3),
    retry.MaxJitter(time.Millisecond*500),
)
```

**配置要点**:
- `Delay`: 基础重试间隔
- `Attempts`: 最大重试次数
- `MaxJitter`: 随机抖动，避免雷击效应

**推荐库**:
- `github.com/avast/retry-go`（简单）
- `github.com/sethvargo/go-retry`（强大）

---

## JSON 解析

### GJSON（推荐）

```go
import "github.com/tidwall/gjson"

json := `{"name": "Tom", "age": 18}`

// 获取值
name := gjson.Get(json, "name").String()
age := gjson.Get(json, "age").Int()

// 路径查找
value := gjson.Get(json, "friends.0.name")

// 解析数组
results := gjson.Get(json, "users.#.age").Array()
```

**优点**: 
- 无需定义结构体
- 支持路径查找
- 高性能

**适用**: 解析未知结构、快速提取字段

---

## 类型转换（Cast）

### spf13/cast（推荐）

```go
import "github.com/spf13/cast"

// 转 int
i := cast.ToInt("123")

// 转 string
s := cast.ToString(123)

// 转 bool
b := cast.ToBool("true")

// 转 slice
sl := cast.ToIntSlice([]string{"1", "2", "3"})
```

**优点**: 
- 统一的类型转换接口
- 支持所有基础类型
- 错误处理友好

**适用**: 处理用户输入、配置解析

---

## HTTP 客户端

### Resty（推荐）

```go
import "github.com/go-resty/resty/v2"

client := resty.New()

// GET
resp, err := client.R().
    SetQueryParam("page", "1").
    SetHeader("Accept", "application/json").
    Get("https://api.example.com/users")

// POST
resp, err := client.R().
    SetBody(userInfo).
    SetResult(&result).
    Post("https://api.example.com/users")

// 自动重试
client.
    SetRetryCount(3).
    SetRetryWaitTime(1 * time.Second).
    AddRetryCondition(func(r *resty.Response, err error) bool {
        return err != nil  // 有错误就重试
    })
```

**优点**: 链式调用、自动重试、调试模式
**库**: `github.com/go-resty/resty/v2`

---

## 配置管理

### Viper（推荐）

```go
import "github.com/spf13/viper"

viper.SetConfigName("config")
viper.SetConfigType("yaml")
viper.AddConfigPath(".")
viper.ReadInConfig()

// 读取
port := viper.GetInt("server.port")
debug := viper.GetBool("server.debug")

// 监听配置变化
viper.WatchConfig()
viper.OnConfigChange(func(e fsnotify.Event) {
    // 重新加载配置
})
```

**优点**: 支持多种格式、监听变化、默认值
**库**: `github.com/spf13/viper`

---

## 日志

### Zap（推荐）

```go
import "go.uber.org/zap"

logger, _ := zap.NewProduction()
defer logger.Sync()

// 结构化日志
logger.Info("user login",
    zap.String("user_id", "123"),
    zap.Duration("latency", latency),
)

// 错误日志
logger.Error("failed to fetch user",
    zap.Error(err),
    zap.String("user_id", "123"),
)
```

**优点**: 高性能、结构化、零分配
**库**: `go.uber.org/zap`

---

## 🚨 NEVER List

### 1. 绝不忽略熔断器

```go
// ❌ WRONG - 直接调用，无熔断
result, err := callAPI()

// ✅ RIGHT - 通过熔断器
result, err := cb.Execute(func() (interface{}, error) {
    return callAPI()
})
```

---

### 2. 绝不无限重试

```go
// ❌ WRONG - 无限重试
for {
    if err := call(); err == nil {
        break
    }
    time.Sleep(time.Second)  // 会永久阻塞
}

// ✅ RIGHT - 限制重试次数
err := retry.Do(call, retry.Attempts(3))
```

---

### 3. 绝不在缓存里存大对象

```go
// ❌ WRONG - 缓存整个数据库表
cache.Set("users", allUsers, time.Hour)  // 可能几百 MB

// ✅ RIGHT - 缓存单个用户
cache.Set(fmt.Sprintf("user:%d", userID), user, time.Hour)
```

---

## Tips（快速参考）

- ✅ 限流用 `golang.org/x/time/rate`（令牌桶）
- ✅ 熔断用 `github.com/sony/gobreaker`
- ✅ 缓存用 `github.com/dgraph-io/ristretto` 或 `ccache`
- ✅ 重试用 `github.com/avast/retry-go`
- ✅ JSON 用 `github.com/tidwall/gjson`
- ✅ 转换用 `github.com/spf13/cast`
- ✅ HTTP 用 `github.com/go-resty/resty`
- ✅ 配置用 `github.com/spf13/viper`
- ✅ 日志用 `go.uber.org/zap`
- ❌ 不要忽略熔断和重试
- ❌ 不要在缓存里存大对象
