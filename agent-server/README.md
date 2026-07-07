# Life Midpoint Agent Server

本地日记页 Agent 后端服务。

> 项目整体的一键启动方式见根目录 [README.md](../README.md)；这份文档只讲 agent-server 本身。

## 能力

- `POST /api/diary/chat`: 用户发一条消息, 服务端用同一个会话上下文分别生成:
  - `grandma`: 老奶奶人格
  - `girl`: 小女孩人格
- `POST /api/diary/summary`: 把一段对话历史总结成日记标题 + 正文
- `POST /api/letter/assist`: 写信页 AI 写作助手, `action` 为 `continue`(续写) 或 `polish`(润色)
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

## 模型配置 (GLM-5.2)

服务使用 OpenAI 兼容格式调用 LLM, 默认指向智谱 GLM-5.2 (`https://open.bigmodel.cn/api/paas/v4`)。
切换其他 OpenAI 兼容模型只需改 `.env`, 无需改代码。

默认读取本目录下的 `.env` (已被 `.gitignore` 忽略, 不会提交):

```text
agent-server/.env
```

首次使用请复制示例并填入 key:

```sh
cp agent-server/.env.example agent-server/.env
# 然后编辑 .env, 填入 LLM_API_KEY
```

可用变量:

```text
LLM_API_KEY=...                                       # 必填
LLM_BASE_URL=https://open.bigmodel.cn/api/paas/v4     # 可选
LLM_MODEL=glm-5.2                                     # 可选
```

如需使用其他位置的 env 文件:

```sh
AGENT_ENV_PATH=/path/to/.env bun run dev
```

## 监听地址 (模拟器 vs 真机)

默认只监听 `127.0.0.1` (仅本机可访问, 更安全)。iOS 模拟器和宿主 Mac 共享网络栈, 127.0.0.1 就能访问, 不需要改任何东西。

真机调试时手机上的 127.0.0.1 指向手机自己, 必须让服务监听到局域网网卡上, 才能被手机连到:

```sh
AGENT_HOST=0.0.0.0 bun run dev
```

`../run.sh device` 会自动做这件事, 并把 Mac 的 Bonjour 主机名 (`xxx.local`) 编译进 App 里, 手动执行 `bun run dev` 一般用不到这个变量。

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
