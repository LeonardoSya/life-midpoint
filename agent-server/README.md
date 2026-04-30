# Life Midpoint Agent Server

本地日记页 Agent 后端服务。

## 能力

- `POST /api/diary/chat`: 用户发一条消息, 服务端用同一个会话上下文分别生成:
  - `grandma`: 老奶奶人格
  - `girl`: 小女孩人格
- `GET /health`: 健康检查
- `POST /api/diary/sessions/:sessionId/reset`: 清空某个本地内存会话

## 启动

### 推荐: 直接从 Xcode Run

项目已通过 `project.yml` 注册 Debug pre-build script:

```text
scripts/start_agent_server.sh
```

因此在 Xcode 里点 Run，或执行一次 Debug `xcodebuild`，会自动:

1. 检查 `http://127.0.0.1:8787/health`
2. 已运行则跳过
3. 未运行则后台启动 `agent-server`
4. 日志写入 `tmp/agent-server/agent-server.log`

### 手动启动

```sh
cd agent-server
bun install
bun run dev
```

默认读取模型配置:

```text
$HOME/clawd-project/the-next/packages/app/.env
```

该文件只在运行时读取, 不会复制到本仓库。

如需使用其他位置:

```sh
AGENT_ENV_PATH=/path/to/.env bun run dev
```

## 请求示例

```sh
curl -X POST http://127.0.0.1:8787/api/diary/chat \
  -H 'Content-Type: application/json' \
  -d '{"message":"我今天有点累。"}'
```

响应:

```json
{
  "sessionId": "...",
  "replies": [
    { "persona": "grandma", "displayName": "奶奶", "content": "..." },
    { "persona": "girl", "displayName": "小女孩", "content": "..." }
  ]
}
```
