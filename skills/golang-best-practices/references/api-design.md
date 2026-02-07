# API 设计决策与权衡

## 核心原则

API 设计是**契约**，一旦发布就很难改。设计时要考虑版本兼容性和扩展性。

---

## 🚨 NEVER List（常见陷阱）

### 1. 绝不使用单数资源名

```go
// ❌ WRONG - 单数
GET /author/12
POST /author

// ✅ RIGHT - 复数
GET /authors/12
POST /authors
```

**WHY**: 复数形式更一致，避免混淆（是获取一个作者还是列表？）。

---

### 2. 绝不使用多级路径嵌套

```go
// ❌ WRONG - 三级嵌套
GET /authors/12/categories/2/posts/3

// ✅ RIGHT - 扁平化
GET /authors/12?categories=2&posts=3
GET /posts/3?authorId=12&categoryId=2
```

**WHY**: 超过两级嵌套会使 URL 难以维护和缓存。

---

### 3. 绝不省略版本号

```go
// ❌ WRONG - 无版本
GET /users/123

// ✅ RIGHT - 有版本
GET /api/v1/users/123
GET /api/v2/users/123  // 可以有 breaking changes
```

**WHY**: 一旦 API 发布，改字段就是 breaking change。版本号允许不兼容的修改。

---

### 4. URI 结尾绝不加 `/`

```go
// ❌ WRONG - 有斜杠
GET /users/

// ✅ RIGHT - 无斜杠
GET /users
```

**WHY**: 结尾的 `/` 会导致 `users` 和 `users/` 被视为两个不同的 URL，造成缓存和日志混乱。

---

### 5. 绝不用 GET 修改数据

```go
// ❌ WRONG - GET 修改数据
GET /deleteUser/123
GET /createUser?name=Tom

// ✅ RIGHT - 用正确的 HTTP 方法
DELETE /users/123
POST /users
```

**WHY**: GET 可能被缓存和预取，导致意外的数据修改。

---

## HTTP 方法语义决策

### CRUD 操作映射

| 操作 | HTTP 方法 | 幂等性 | 说明 |
|------|-----------|--------|------|
| 查询 | `GET` | ✓ | 安全，可缓存 |
| 新增 | `POST` | ✗ | 非幂等，每次创建新资源 |
| 创建/替换 | `PUT` | ✓ | 幂等，多次调用结果相同 |
| 部分修改 | `PATCH` | ✗ | 只修改提供的字段 |
| 删除 | `DELETE` | ✓ | 幂等，删除不存在的资源也是成功 |

### POST vs PUT（常见混淆）

```
完全替换资源？ → PUT（幂等）
   └─ 创建新资源（ID 由客户端指定） → PUT

创建新资源（ID 由服务端生成）？ → POST

部分修改？ → PATCH
```

---

## HTTP 状态码选择

### 成功响应（2xx）

| 状态码 | 含义 | 使用场景 |
|--------|------|---------|
| 200 | OK | 查询成功、修改成功 |
| 201 | Created | 创建成功，响应头包含 Location |
| 204 | No Content | 删除成功、PUT 成功但无需返回内容 |

**决策**: 创建资源用 201，删除用 204（或 200），其他用 200。

---

### 客户端错误（4xx）

| 状态码 | 含义 | 使用场景 |
|--------|------|---------|
| 400 | Bad Request | 请求参数错误 |
| 401 | Unauthorized | 未认证（未登录） |
| 403 | Forbidden | 已认证但无权限 |
| 404 | Not Found | 资源不存在 |
| 409 | Conflict | 资源冲突（如唯一索引冲突） |
| 422 | Unprocessable Entity | 参数格式正确但语义错误 |
| 429 | Too Many Requests | 超过限流 |

**常见错误**: 用 400 返回所有错误。应该细化：
- 未登录 → 401
- 无权限 → 403
- 不存在 → 404
- 业务冲突 → 409

---

### 服务器错误（5xx）

| 状态码 | 含义 | 使用场景 |
|--------|------|---------|
| 500 | Internal Server Error | 未预期的服务器错误 |
| 502 | Bad Gateway | 上游服务错误 |
| 503 | Service Unavailable | 服务过载或维护中 |

**原则**: 客户端错误用 4xx，服务器错误用 5xx。

---

## 业务错误码设计

### 是否统一返回 200？

```
方案 1: 统一 200 + 业务 code（Facebook、Bilibili）
HTTP/1.1 200 OK
{
  "code": 100101,
  "msg": "用户不存在",
  "data": null
}

优点: 客户端处理统一
缺点: 不符合 HTTP 语义，无法用 HTTP 缓存

方案 2: 用 HTTP code 表示错误（Twitter、Bing）
HTTP/1.1 404 Not Found
{
  "code": 100101,
  "msg": "用户不存在",
  "data": null
}

优点: 符合 HTTP 语义，可用 HTTP 缓存
缺点: 客户端需要处理多种状态码
```

**推荐**: 方案 2（除非是移动端 App，统一 200 更简单）。

---

### 业务 code 结构

```
10 01 01
│  │  └─ 具体错误标号（0-99）
│  └──── 模块号（0-99）
└─────── 服务号（0-99）
```

示例：
- `100101` = 用户服务(10) 的认证模块(01) 的"用户不存在"错误(01)
- `200503` = 订单服务(20) 的支付模块(05) 的"余额不足"错误(03)

---

## 批量操作设计

### 方案选择

```
简单批量（< 10 项）？ → 用数组参数
   └─ GET /users?ids=1,2,3,4,5

复杂批量（> 10 项）？ → 用 POST + 数组
   └─ POST /users/batch
      Body: {"ids": [1,2,3,4,5,6,7,8,9,10]}

批量修改/删除？ → 统一用 POST + method 字段
   └─ POST /api/resources
      Body: {
        "method": "delete",
        "data": [1, 2, 3]
      }
```

---

## gRPC vs REST（技术选型）

### 决策树

```
内部服务间通信？ → gRPC
   ├─ 需要强类型约束 → gRPC
   ├─ 需要高性能 → gRPC
   └─ 需要流式传输 → gRPC

外部 API（给前端/第三方）？ → REST + JSON
   └─ 兼容性要求高 → REST
```

### gRPC 优势

- **性能**: Protobuf 二进制编码，比 JSON 小
- **流式**: 支持 4 种流模式（unary, client stream, server stream, bidi stream）
- **强约束**: IDL 自动生成代码，避免运行时错误
- **HTTP/2**: 多路复用，避免队头阻塞

### REST 优势

- **兼容性**: 所有语言都支持 JSON
- **调试**: 可以直接用 curl/Postman 测试
- **缓存**: HTTP 缓存机制天然支持
- **浏览器**: 前端可以直接调用

---

## 分页设计

### Cursor vs Offset

```go
// 方案 1: Offset 分页（简单但性能差）
GET /users?page=1&limit=20

优点: 实现简单，可以跳页
缺点: 大 offset 性能差，数据不一致时会跳过或重复

// 方案 2: Cursor 分页（复杂但性能好）
GET /users?limit=20&cursor=MTUzMTQzNjM5Mw

优点: 性能好，数据一致
缺点: 无法跳页，只能下一页/上一页
```

**推荐**: 
- 内部管理后台 → Offset（需要跳页）
- 公共 API（大量数据）→ Cursor（性能优先）

---

## 限流与配额

### 限流维度

```
用户级限流？ → 按 user_id 或 API key
   ├─ 防止单个用户占用过多资源

IP 级限流？ → 按 IP 地址
   └─ 防止恶意请求

全局限流？ → 保护服务整体
   └─ 防止服务过载
```

### 限流算法

| 算法 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| **令牌桶** | 允许突发 | 实现复杂 | API 限流 |
| **漏桶** | 恒定速率 | 不允许突发 | 消息队列 |
| **固定窗口** | 简单 | 边界突刺 | 简单场景 |
| **滑动窗口** | 精确 | 内存占用大 | 精确限流 |

**推荐**: 令牌桶（`golang.org/x/time/rate`）

---

## Tips（快速参考）

- ✅ URI 用复数：`/users` 不是 `/user`
- ✅ 加入版本号：`/api/v1/users`
- ✅ 结尾不加 `/`：`/users` 不是 `/users/`
- ✅ 用正确的 HTTP 方法：GET 查、POST 增、PUT 改、DELETE 删
- ✅ 状态码细化：401 未登录、403 无权限、404 不存在
- ❌ 不要用 GET 修改数据
- ❌ 不要超过两级路径嵌套
- ❌ 不要省略版本号
