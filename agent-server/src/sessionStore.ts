import { LIMITS } from './config'
import type { ClientMessage, ClientSpeaker, SessionMessage, SessionState } from './types'

const sessions = new Map<string, SessionState>()

function nowISO(): string {
  return new Date().toISOString()
}

export function getOrCreateSession(sessionId?: string): SessionState {
  evictStaleSessions()

  if (sessionId) {
    const existing = sessions.get(sessionId)
    if (existing) return existing
  }

  const id = sessionId && sessionId.length <= 80 ? sessionId : crypto.randomUUID()
  const createdAt = nowISO()
  const state: SessionState = { id, messages: [], createdAt, updatedAt: createdAt }
  sessions.set(id, state)
  return state
}

function evictStaleSessions(): void {
  const now = Date.now()

  for (const [id, session] of sessions) {
    if (now - Date.parse(session.updatedAt) > LIMITS.sessionTtlMs) {
      sessions.delete(id)
    }
  }

  if (sessions.size < LIMITS.maxSessions) return

  const sorted = [...sessions.entries()]
    .sort((a, b) => Date.parse(a[1].updatedAt) - Date.parse(b[1].updatedAt))

  const overflow = sessions.size - LIMITS.maxSessions + 1
  for (const [id] of sorted.slice(0, overflow)) {
    sessions.delete(id)
  }
}

export function resetSession(sessionId: string): boolean {
  return sessions.delete(sessionId)
}

export function appendMessage(session: SessionState, speaker: ClientSpeaker, content: string): void {
  session.messages.push({ speaker, content, createdAt: nowISO() })
  session.messages = session.messages.slice(-LIMITS.maxSessionMessages)
  session.updatedAt = nowISO()
}

export function normalizeExternalHistory(history: ClientMessage[] | undefined): SessionMessage[] {
  if (!Array.isArray(history)) return []

  return history
    .slice(-LIMITS.maxHistoryMessages)
    .map((item): SessionMessage | null => {
      const speaker = item.speaker ?? item.role ?? 'assistant'
      if (!['user', 'grandma', 'girl', 'assistant'].includes(speaker)) return null

      const content = typeof item.content === 'string' ? item.content.trim() : ''
      if (!content) return null

      return { speaker, content: content.slice(0, LIMITS.maxMessageChars), createdAt: nowISO() }
    })
    .filter((item): item is SessionMessage => item !== null)
}

export function mergedContext(session: SessionState, externalHistory: SessionMessage[]): SessionMessage[] {
  if (externalHistory.length === 0) return session.messages.slice(-LIMITS.maxHistoryMessages)
  return [...externalHistory, ...session.messages].slice(-LIMITS.maxHistoryMessages)
}

export function sessionCount(): number {
  return sessions.size
}
