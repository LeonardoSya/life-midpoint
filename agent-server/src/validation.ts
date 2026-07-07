import { LIMITS } from './config'
import type { DiaryChatRequest, DiarySummaryRequest, LetterAssistAction, LetterAssistRequest } from './types'

export class HttpError extends Error {
  constructor(public readonly status: number, message: string) {
    super(message)
  }
}

export async function readJson(request: Request): Promise<unknown> {
  const contentLength = Number(request.headers.get('content-length') ?? '0')
  if (contentLength > LIMITS.requestBodyBytes) {
    throw new HttpError(413, 'Request body too large')
  }

  const buffer = await request.arrayBuffer()
  if (buffer.byteLength > LIMITS.requestBodyBytes) {
    throw new HttpError(413, 'Request body too large')
  }

  try {
    return JSON.parse(new TextDecoder().decode(buffer))
  } catch {
    throw new HttpError(400, 'Invalid JSON body')
  }
}

/// `history` 字段在 chat / summary 两个请求体里格式完全一致, 抽成共享解析函数.
function parseHistory(body: Record<string, unknown>) {
  return Array.isArray(body.history)
    ? body.history.slice(-LIMITS.maxHistoryMessages).map((item) => {
      if (!item || typeof item !== 'object') return { content: '' }
      const record = item as Record<string, unknown>
      return {
        role: typeof record.role === 'string' ? record.role : undefined,
        speaker: typeof record.speaker === 'string' ? record.speaker : undefined,
        content: typeof record.content === 'string' ? record.content.slice(0, LIMITS.maxMessageChars) : '',
      }
    })
    : undefined
}

function parseSessionId(body: Record<string, unknown>): string | undefined {
  return typeof body.sessionId === 'string' && body.sessionId.trim()
    ? body.sessionId.trim().slice(0, 80)
    : undefined
}

export function parseDiaryChatRequest(input: unknown): DiaryChatRequest {
  if (!input || typeof input !== 'object') {
    throw new HttpError(400, 'Request body must be an object')
  }

  const body = input as Record<string, unknown>
  const message = typeof body.message === 'string' ? body.message.trim() : ''

  if (!message) throw new HttpError(400, '`message` is required')
  if (message.length > LIMITS.maxMessageChars) {
    throw new HttpError(400, `message must be <= ${LIMITS.maxMessageChars} characters`)
  }

  return { sessionId: parseSessionId(body), message, history: parseHistory(body) }
}

export function parseDiarySummaryRequest(input: unknown): DiarySummaryRequest {
  if (!input || typeof input !== 'object') {
    throw new HttpError(400, 'Request body must be an object')
  }

  const body = input as Record<string, unknown>
  const sessionId = parseSessionId(body)
  const history = parseHistory(body)

  if (!sessionId && (!history || history.length === 0)) {
    throw new HttpError(400, '`sessionId` or `history` is required')
  }

  return { sessionId, history }
}

const LETTER_ASSIST_ACTIONS: LetterAssistAction[] = ['continue', 'polish']

export function parseLetterAssistRequest(input: unknown): LetterAssistRequest {
  if (!input || typeof input !== 'object') {
    throw new HttpError(400, 'Request body must be an object')
  }

  const body = input as Record<string, unknown>
  const action = typeof body.action === 'string' ? body.action : ''
  if (!LETTER_ASSIST_ACTIONS.includes(action as LetterAssistAction)) {
    throw new HttpError(400, '`action` must be one of "continue" | "polish"')
  }

  const draft = typeof body.draft === 'string' ? body.draft.slice(0, LIMITS.maxMessageChars) : ''
  if (action === 'polish' && !draft.trim()) {
    throw new HttpError(400, '`draft` is required for polish')
  }

  return { action: action as LetterAssistAction, draft }
}
