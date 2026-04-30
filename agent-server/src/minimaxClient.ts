import type { ModelConfig, ModelMessage } from './types'
import { LIMITS } from './config'

interface OpenAIChatChoice {
  message?: {
    content?: string
  }
}

interface OpenAIChatResponse {
  choices?: OpenAIChatChoice[]
  error?: {
    message?: string
  }
}

export class MiniMaxClient {
  constructor(private readonly config: ModelConfig) {}

  async chat(messages: ModelMessage[], options: { compact?: boolean } = { compact: true }): Promise<string> {
    const response = await fetch(`${this.config.baseURL}/chat/completions`, {
      method: 'POST',
      signal: AbortSignal.timeout(LIMITS.modelTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${this.config.apiKey}`,
      },
      body: JSON.stringify({
        model: this.config.model,
        messages,
        temperature: 0.72,
        max_tokens: options.compact === false ? 1200 : 320,
      }),
    })

    const payload = await response.json().catch(() => ({})) as OpenAIChatResponse

    if (!response.ok) {
      const message = payload.error?.message ?? `MiniMax request failed (${response.status})`
      throw new Error(message)
    }

    const content = payload.choices?.[0]?.message?.content?.trim()
    if (!content) throw new Error('MiniMax response did not include message content')

    return options.compact === false ? stripThinking(content) : compactOneSentence(content)
  }
}

/**
 * 模型偶尔会返回多句或带角色名前缀。这里做轻量清洗, 保持 UI 气泡是一句话。
 */
export function compactOneSentence(raw: string): string {
  const withoutThinking = stripThinking(raw)

  const withoutRole = withoutThinking
    .replace(/^(奶奶|老奶奶|小女孩|女孩|grandma|girl)\s*[:：]\s*/i, '')
    .replace(/^["“”'「」]+|["“”'「」]+$/g, '')
    .trim()

  if (!withoutRole) {
    return '我在这里，先陪你把这口气慢慢放下来。'
  }

  const match = withoutRole.match(/^(.+?[。！？!?])/)
  const sentence = (match?.[1] ?? withoutRole).trim()
  return sentence.length > 80 ? `${sentence.slice(0, 78)}…` : sentence
}

export function stripThinking(raw: string): string {
  const afterClosedThink = raw.includes('</think>')
    ? raw.slice(raw.lastIndexOf('</think>') + '</think>'.length)
    : raw

  return afterClosedThink
    // 兜底: 完整 think block
    .replace(/<think>[\s\S]*?<\/think>/gi, '')
    // 兜底: 标签残留
    .replace(/<\/?think>/gi, '')
    .replace(/^(思考|分析|推理)[:：][\s\S]*?(?=\n|$)/i, '')
    .trim()
}
