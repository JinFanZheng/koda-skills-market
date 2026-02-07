# 并发编程避坑指南

## 核心原则

### 决策树：选择合适的并发原语

```
需要保护共享状态？
├─ 是 → 简单类型？ → Atomic
│        └─ 否 → 读写多？ → RWMutex
│                └─ 否 → Mutex
└─ 否 → 需要传递数据？ → Channel
         └─ 仅需信号？ → sync.Cond 或等待组
```

### 权衡分析

| 方案 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| **Mutex** | 简单易用 | 性能较低，可能死锁 | 临界区小、逻辑简单 |
| **RWMutex** | 读多写少时性能好 | 写操作会阻塞所有读 | 读多写少的缓存、配置 |
| **Atomic** | 零开销，性能最高 | 只支持简单类型 | 计数器、标志位 |
| **Channel** | 类型安全，避免死锁 | 性能开销大 | goroutine 间通信 |

---

## 🚨 NEVER List（生产环境血泪教训）

### 1. 绝不在 for 循环里 defer

```go
// ❌ WRONG - 内存泄露
for _, file := range files {
    defer file.Close()  // 所有 defer 在函数退出时才执行
}

// ✅ RIGHT - 匿名函数立即执行
for _, file := range files {
    func(f *os.File) {
        defer f.Close()
        // 处理文件
    }(file)
}
```

**WHY**: defer 在函数退出时才执行，循环中所有文件句柄会累积到函数结束，导致资源泄露。

---

### 2. 绝不直接关闭多写多读的 channel

```go
// ❌ WRONG - 可能 panic
ch := make(chan int, 10)
for i := 0; i < 10; i++ {
    go func() {
        ch <- i  // 多个 writer
    }()
}
close(ch)  // 其他 goroutine 再写入会 panic

// ✅ RIGHT - 用 context/stop channel 控制
ch := make(chan int, 10)
stop := make(chan struct{})

for i := 0; i < 10; i++ {
    go func() {
        select {
        case ch <- i:
        case <-stop:
            return
        }
    }()
}
close(stop)  // 安全退出
```

**WHY**: 多个 writer 同时写入已关闭的 channel 会 panic。必须用单独的 stop channel 或 context。

---

### 3. 绝不忘记停止用于超时的 timer

```go
// ❌ WRONG - 内存泄露
func doWork() {
    timer := time.NewTimer(5 * time.Second)
    select {
    case <-timer.C:
        // 超时处理
    case result := <-ch:
        // 正常返回
    }
    // timer.C 没有被读取，timer 没停止，goroutine 泄露
}

// ✅ RIGHT - 总是停止 timer
func doWork() {
    timer := time.NewTimer(5 * time.Second)
    defer timer.Stop()  // 重要！

    select {
    case <-timer.C:
    case result := <-ch:
    }
}
```

**WHY**: 未停止的 timer 会持续占用资源，导致 goroutine 和内存泄露。

---

### 4. 绝不在持有锁时调用外部函数

```go
// ❌ WRONG - 可能死锁
mu.Lock()
result := expensiveFunction()  // 如果这个函数内部也请求锁 → 死锁
mu.Unlock()

// ✅ RIGHT - 减小临界区
var result T
mu.Lock()
data := criticalData
mu.Unlock()

result = expensiveFunction(data)  // 无锁执行
```

**WHY**: 外部函数可能内部也请求锁，造成死锁。临界区应该尽可能小。

---

### 5. 绝不复制含锁的结构体

```go
type SafeCounter struct {
    mu    sync.Mutex
    count int
}

// ❌ WRONG - 锁被复制，失效
func (c SafeCounter) Increment() {  // 值接收器
    c.mu.Lock()
    c.count++
    c.mu.Unlock()
}

// ✅ RIGHT - 指针接收器
func (c *SafeCounter) Increment() {  // 指针接收器
    c.mu.Lock()
    c.count++
    c.mu.Unlock()
}
```

**WHY**: 值复制时锁也被复制，新的锁状态与原锁无关，保护失效。

---

## Goroutine 泄露排查

### 泄露场景检查表

```
1. 有阻塞的 channel 操作吗？
   ├─ 发送但无接收 → goroutine 永久阻塞
   └─ 接收但无发送 → goroutine 永久阻塞

2. 有忘记停止的 timer 吗？
   └─ time.NewTimer() 未调用 Stop()

3. context 取消了吗？
   └─ 子 goroutine 没监听 ctx.Done()

4. select 有默认分支吗？
   └─ 所有 case 都阻塞，无 default
```

### 排查工具

```bash
# 检测 goroutine 数量
curl http://localhost:6060/debug/pprof/goroutine?debug=1

# 可视化 goroutine
go tool pprof http://localhost:6060/debug/pprof/goroutine
(goroutine) top
(goroutine) list <function>
```

---

## Context 使用决策

### Context 类型选择

| 类型 | 用途 | 何时取消 |
|------|------|---------|
| `Background()` | 根 context | 永不 |
| `TODO()` | 临时占位 | 永不（应替换） |
| `WithCancel()` | 手动取消 | `cancel()` 被调用 |
| `WithTimeout()` | 超时控制 | 超时或 `cancel()` |
| `WithDeadline()` | 截止时间 | 到期或 `cancel()` |
| `WithValue()` | 传递元数据 | 继承父级 |

### Context 传播规则

```
HTTP Request → Background → WithTimeout(3s)
                          ├─ handler: ctx
                          ├─ service: ctx
                          └─ dao: ctx
                              ├─ query: ctx
                              └─ cache: ctx (可以缩短超时)
```

**重要原则**:
1. **永远不要在 struct 里存储 context**
2. **context 应该是第一个参数**
3. **不要传递 nil context**，用 `context.Background()`

---

## Channel 关闭决策

### 谁应该关闭 channel？

```
Single Producer, Single Consumer → Producer 关闭
Single Producer, Multiple Consumers → Producer 关闭
Multiple Producers, Single Consumer → 不要直接关闭！
Multiple Producers, Multiple Consumers → 不要直接关闭！
```

### 多生产者安全关闭模式

```go
// 使用 stop channel
type Worker struct {
    jobs   chan int
    stop   chan struct{}
}

func (w *Worker) Start() {
    go func() {
        for {
            select {
            case job := <-w.jobs:
                process(job)
            case <-w.stop:
                return
            }
        }
    }()
}

func (w *Worker) Stop() {
    close(w.stop)  // 安全关闭
}
```

---

## 性能优化决策

### sync.Pool 使用场景

```
需要重复创建对象？ → 对象创建成本高？ → 用 sync.Pool
                       └─ 否 → 直接创建
```

**适用**: 高频临时对象（byte buffer、解析器）
**不适用**: 长生命周期对象、连接池

### sync.Map vs map + Mutex

| 方案 | 读多写少 | 写多 | 缓存命中 |
|--------|---------|------|---------|
| **map + Mutex** | ✓ | ✓ | ✗ |
| **sync.Map** | ✓✓✓ | ✗ | ✓✓ |

**决策**: 读多写少用 sync.Map，否则用 map + Mutex。

---

## 性能分析工具链

### 问题定位决策树

```
CPU 高？
├─ pprof cpu → 哪个函数慢？
└─ trace → 锁竞争？调度延迟？

内存高？
├─ pprof heap → 谁分配多？
└─ pprof allocs → 谁分配频繁？

goroutine 多？
└─ pprof goroutine → 谁创建的？为什么没退出？
```

### 常用命令

```bash
# CPU 性能
go test -bench=. -cpuprofile=cpu.prof
go tool pprof cpu.prof
(pprof) top
(pprof) list functionName

# 内存分析
go test -bench=. -memprofile=mem.prof
go tool pprof mem.prof
(pprof) top
(pprof) list functionName

# goroutine 泄露
curl localhost:6060/debug/pprof/goroutine?debug=1 > goroutine.txt
go tool pprof -http=:8080 http://localhost:6060/debug/pprof/goroutine
```

---

## 容错与可靠性

### 降级策略决策

```
核心服务？
├─ 是 → 多级降级（缓存 → 默认值 → 快速失败）
└─ 否 → 单级降级（直接快速失败）
```

### 限流熔断配合

```
请求 → 限流器 → 熔断器 → 服务
       ↓         ↓
     拒绝     降级
```

**配置顺序**: 限流 → 熔断 → 降级 → 超时

---

## Tips（快速参考）

- ✅ 返回竞争容器时 deepcopy
- ✅ 返回单向 channel
- ❌ 不能复制含锁的结构
- ❌ 不能在 for 循环里 defer
- ✅ for range map delete key 是安全的
- ✅ 超时 timer 在函数退出时 stop
- ✅ context 是并发安全的
- ❌ 不要传递 nil context
