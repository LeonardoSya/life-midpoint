import type { ModelConfig } from './types'

const DEFAULT_ENV_PATH = `${process.env.HOME ?? ''}/clawd-project/the-next/packages/app/.env`

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

  const apiKey = process.env.MINIMAX_API_KEY
    ?? process.env.VITE_MINIMAX_API_KEY
    ?? fileEnv.MINIMAX_API_KEY
    ?? fileEnv.VITE_MINIMAX_API_KEY

  const baseURL = process.env.MINIMAX_BASE_URL
    ?? process.env.VITE_MINIMAX_BASE_URL
    ?? fileEnv.MINIMAX_BASE_URL
    ?? fileEnv.VITE_MINIMAX_BASE_URL
    ?? 'https://api.minimaxi.com/v1'

  const model = process.env.MINIMAX_MODEL
    ?? process.env.VITE_MINIMAX_MODEL
    ?? fileEnv.MINIMAX_MODEL
    ?? fileEnv.VITE_MINIMAX_MODEL
    ?? 'MiniMax-M2.7'

  if (!apiKey) {
    throw new Error(`MiniMax API key is not configured. Set MINIMAX_API_KEY or provide ${envPath}`)
  }

  return { apiKey, baseURL: baseURL.replace(/\/+$/, ''), model }
}

export function getServerPort(): number {
  const raw = process.env.AGENT_PORT ?? process.env.PORT ?? '8787'
  const port = Number(raw)
  if (!Number.isInteger(port) || port <= 0 || port > 65535) return 8787
  return port
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
