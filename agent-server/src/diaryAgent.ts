import { PERSONA_DISPLAY_NAME, PERSONA_SYSTEM_PROMPTS } from './personas'
import {
  appendMessage,
  getOrCreateSession,
  mergedContext,
  normalizeExternalHistory,
} from './sessionStore'
import type {
  ClientSpeaker,
  DiaryChatRequest,
  DiaryChatResponse,
  DiarySummaryRequest,
  DiarySummaryResponse,
  ModelMessage,
  PersonaId,
  PersonaReply,
  SessionMessage,
} from './types'
import type { MiniMaxClient } from './minimaxClient'

function speakerLabel(speaker: ClientSpeaker): string {
  switch (speaker) {
    case 'user': return '用户'
    case 'grandma': return '奶奶'
    case 'girl': return '小女孩'
    default: return '陪伴者'
  }
}

function contextToModelMessages(context: SessionMessage[]): ModelMessage[] {
  return context.map((message) => ({
    role: message.speaker === 'user' ? 'user' : 'assistant',
    content: `${speakerLabel(message.speaker)}：${message.content}`,
  }))
}

function buildMessages(persona: PersonaId, context: SessionMessage[], userMessage: string): ModelMessage[] {
  return [
    { role: 'system', content: PERSONA_SYSTEM_PROMPTS[persona] },
    ...contextToModelMessages(context),
    { role: 'user', content: `用户：${userMessage}` },
  ]
}

async function generatePersonaReply(
  client: MiniMaxClient,
  persona: PersonaId,
  context: SessionMessage[],
  userMessage: string,
): Promise<PersonaReply> {
  const content = await client.chat(buildMessages(persona, context, userMessage))
  return {
    persona,
    displayName: PERSONA_DISPLAY_NAME[persona],
    content,
  }
}

export async function handleDiaryChat(
  client: MiniMaxClient,
  input: DiaryChatRequest,
): Promise<DiaryChatResponse> {
  const session = getOrCreateSession(input.sessionId)
  const externalHistory = normalizeExternalHistory(input.history)
  const contextBeforeTurn = mergedContext(session, externalHistory)

  appendMessage(session, 'user', input.message)

  const [grandma, girl] = await Promise.all([
    generatePersonaReply(client, 'grandma', contextBeforeTurn, input.message),
    generatePersonaReply(client, 'girl', contextBeforeTurn, input.message),
  ])

  appendMessage(session, 'grandma', grandma.content)
  appendMessage(session, 'girl', girl.content)

  return {
    sessionId: session.id,
    replies: [grandma, girl],
  }
}

function buildSummaryMessages(context: SessionMessage[]): ModelMessage[] {
  const today = new Intl.DateTimeFormat('zh-CN', {
    month: 'long',
    day: 'numeric',
  }).format(new Date())

  return [
    {
      role: 'system',
      content: `
你是「人生中点」日记页的日记整理 agent。
请把用户和两位陪伴者的对话整理成一篇第一人称日记。
输出必须是严格 JSON, 不要 Markdown, 不要解释, 不要 <think>。
JSON 格式:
{
  "moodTitle": "疲惫但平静的晴天",
  "body": "正文..."
}
要求:
- moodTitle 是 6 到 12 个中文字符左右, 概括今天的心理状态和天气/意象。
- body 使用第一人称, 温柔、具体、像真实日记, 180 到 320 个中文字符。
- 不要编造重大事实, 只根据对话合理整理。
- 今天日期是 ${today}, 不要把日期放进 moodTitle。
`.trim(),
    },
    ...contextToModelMessages(context),
    {
      role: 'user',
      content: '请基于以上对话生成今天的日记总结 JSON。',
    },
  ]
}

function parseSummaryJson(raw: string): { moodTitle: string; body: string } {
  const fallbackBody = '今天我认真听见了自己。那些说不清的疲惫、停顿和心事，都在这一刻被轻轻放到纸上。也许我还没有完全弄明白发生了什么，但我愿意先陪自己待一会儿，让心慢慢安静下来。'
  const match = raw.match(/\{[\s\S]*\}/)
  if (!match) {
    const partialTitle = raw.match(/"moodTitle"\s*:\s*"([^"]+)/)?.[1]?.trim()
    const partialBody = raw.match(/"body"\s*:\s*"([\s\S]*)/)?.[1]
      ?.replace(/["}]\s*$/g, '')
      ?.replace(/\\"/g, '"')
      ?.replace(/\\n/g, '\n')
      ?.trim()

    return {
      moodTitle: partialTitle || '疲惫但平静的晴天',
      body: partialBody || raw.trim() || fallbackBody,
    }
  }

  try {
    const parsed = JSON.parse(match[0]) as { moodTitle?: unknown; body?: unknown }
    return {
      moodTitle: typeof parsed.moodTitle === 'string' && parsed.moodTitle.trim()
        ? parsed.moodTitle.trim().slice(0, 20)
        : '疲惫但平静的晴天',
      body: typeof parsed.body === 'string' && parsed.body.trim()
        ? parsed.body.trim()
        : fallbackBody,
    }
  } catch {
    return {
      moodTitle: '疲惫但平静的晴天',
      body: raw.trim() || fallbackBody,
    }
  }
}

function formatDiarySummary(title: string, body: string): string {
  const date = new Intl.DateTimeFormat('zh-CN', {
    month: 'numeric',
    day: 'numeric',
  }).format(new Date()).replace('/', '月') + '日'

  return `${date} ${title}\n\n${body}`
}

export async function handleDiarySummary(
  client: MiniMaxClient,
  input: DiarySummaryRequest,
): Promise<DiarySummaryResponse> {
  const session = getOrCreateSession(input.sessionId)
  const externalHistory = normalizeExternalHistory(input.history)
  const context = mergedContext(session, externalHistory)
  const raw = await client.chat(buildSummaryMessages(context), { compact: false })
  const parsed = parseSummaryJson(raw)
  const summaryText = formatDiarySummary(parsed.moodTitle, parsed.body)

  return {
    sessionId: session.id,
    title: parsed.moodTitle,
    body: parsed.body,
    summaryText,
  }
}
