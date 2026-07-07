import { join } from 'node:path'
import type { ModelConfig } from './types'

// 默认从本服务目录下的 .env 读取 (agent-server/.env, 已被 .gitignore 忽略)。
// 这样配置自包含, 不依赖其他项目目录。
const DEFAULT_ENV_PATH = join(import.meta.dir, '..', '.env')

function parseEnvFile(contents: string): Record<string, string> {
  const env: Record<string, string> = {}

  for (const rawLine of contents.split(/\r?\n/)) {
    const line = rawLine.trim()
    if (!line || line.startsWith('#')) continue

    const eqIndex = line.indexOf('=')
    if (eqIndex <= 0) continue

    const key = line.slice(0, eqIndex).trim()
    let value = line.slice(eqIndex + 1).trim()

    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1)
    }

    env[key] = value
  }

  return env
}

export async function loadModelConfig(envPath = process.env.AGENT_ENV_PATH ?? DEFAULT_ENV_PATH): Promise<ModelConfig> {
  let fileEnv: Record<string, string> = {}

  try {
    const file = Bun.file(envPath)
    if (await file.exists()) {
      fileEnv = parseEnvFile(await file.text())
    }
  } catch {
    // 继续走 process.env; 具体缺项在下面统一报错.
  }

  const pick = (...keys: string[]): string | undefined => {
    for (const key of keys) {
      const fromProcess = process.env[key]
      if (fromProcess) return fromProcess
      const fromFile = fileEnv[key]
      if (fromFile) return fromFile
    }
    return undefined
  }

  const apiKey = pick('LLM_API_KEY')

  const baseURL = pick('LLM_BASE_URL')
    ?? 'https://open.bigmodel.cn/api/paas/v4'

  const model = pick('LLM_MODEL')
    ?? 'glm-5.2'

  if (!apiKey) {
    throw new Error(`LLM API key is not configured. Set LLM_API_KEY or provide ${envPath}`)
  }

  return { apiKey, baseURL: baseURL.replace(/\/+$/, ''), model }
}

export function getServerPort(): number {
  const raw = process.env.AGENT_PORT ?? process.env.PORT ?? '8787'
  const port = Number(raw)
  if (!Number.isInteger(port) || port <= 0 || port > 65535) return 8787
  return port
}

/// 默认只监听本机 loopback (安全, 模拟器够用: iOS Simulator 与宿主 Mac 共享网络栈,
/// 127.0.0.1 即可访问)。真机调试需要局域网内其他设备访问, 此时由
/// `scripts/run.sh device` 显式设置 `AGENT_HOST=0.0.0.0` 开放监听。
export function getServerHost(): string {
  return process.env.AGENT_HOST ?? '127.0.0.1'
}

export const LIMITS = {
  maxMessageChars: 1200,
  maxHistoryMessages: 24,
  maxSessionMessages: 40,
  maxSessions: 200,
  sessionTtlMs: 30 * 60 * 1000,
  requestBodyBytes: 64 * 1024,
  minRequestIntervalMs: 700,
  modelTimeoutMs: 60_000,
}
