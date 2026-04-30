import { resetSession, sessionCount } from './sessionStore'
import { LIMITS } from './config'
import { HttpError, parseDiaryChatRequest, parseDiarySummaryRequest, readJson } from './validation'
import { handleDiaryChat, handleDiarySummary } from './diaryAgent'
import type { MiniMaxClient } from './minimaxClient'

const corsHeaders = {
  // Intentionally no wildcard Access-Control-Allow-Origin.
  // The iOS app does not need CORS, and omitting it prevents arbitrary web pages
  // from reading responses from the local agent server.
  'Access-Control-Allow-Methods': 'GET,POST,OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
}

let lastChatRequestAt = 0

export function json(data: unknown, init: ResponseInit = {}): Response {
  return new Response(JSON.stringify(data), {
    ...init,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      ...corsHeaders,
      ...(init.headers ?? {}),
    },
  })
}

function notFound(): Response {
  return json({ error: 'Not found' }, { status: 404 })
}

export function createHandler(client: MiniMaxClient) {
  return async function handler(request: Request): Promise<Response> {
    const url = new URL(request.url)

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders })
    }

    try {
      if (request.method === 'GET' && url.pathname === '/health') {
        return json({ ok: true, service: 'life-midpoint-agent', sessions: sessionCount() })
      }

      if (request.method === 'POST' && url.pathname === '/api/diary/chat') {
        const now = Date.now()
        if (now - lastChatRequestAt < LIMITS.minRequestIntervalMs) {
          return json({ error: 'Rate limited' }, { status: 429 })
        }
        lastChatRequestAt = now

        const body = await readJson(request)
        const input = parseDiaryChatRequest(body)
        const result = await handleDiaryChat(client, input)
        return json(result)
      }

      if (request.method === 'POST' && url.pathname === '/api/diary/summary') {
        const body = await readJson(request)
        const input = parseDiarySummaryRequest(body)
        const result = await handleDiarySummary(client, input)
        return json(result)
      }

      const resetMatch = url.pathname.match(/^\/api\/diary\/sessions\/([^/]+)\/reset$/)
      if (request.method === 'POST' && resetMatch) {
        const sessionId = decodeURIComponent(resetMatch[1])
        return json({ ok: true, deleted: resetSession(sessionId) })
      }

      return notFound()
    } catch (error) {
      if (error instanceof HttpError) {
        return json({ error: error.message }, { status: error.status })
      }

      console.error('[agent-server] request failed:', error)
      return json({ error: 'Internal server error' }, { status: 500 })
    }
  }
}
