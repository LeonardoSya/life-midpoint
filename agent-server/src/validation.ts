import { LIMITS } from './config'
import type { DiaryChatRequest, DiarySummaryRequest } from './types'

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

  const sessionId = typeof body.sessionId === 'string' && body.sessionId.trim()
    ? body.sessionId.trim().slice(0, 80)
    : undefined

  const history = Array.isArray(body.history)
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

  return { sessionId, message, history }
}

export function parseDiarySummaryRequest(input: unknown): DiarySummaryRequest {
  if (!input || typeof input !== 'object') {
    throw new HttpError(400, 'Request body must be an object')
  }

  const body = input as Record<string, unknown>
  const sessionId = typeof body.sessionId === 'string' && body.sessionId.trim()
    ? body.sessionId.trim().slice(0, 80)
    : undefined

  const history = Array.isArray(body.history)
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

  if (!sessionId && (!history || history.length === 0)) {
    throw new HttpError(400, '`sessionId` or `history` is required')
  }

  return { sessionId, history }
}
