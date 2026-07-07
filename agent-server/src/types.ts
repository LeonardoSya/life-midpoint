export type PersonaId = 'grandma' | 'girl'

export type ClientSpeaker = 'user' | PersonaId | 'assistant'

export interface ClientMessage {
  role?: ClientSpeaker
  speaker?: ClientSpeaker
  content: string
}

export interface DiaryChatRequest {
  sessionId?: string
  message: string
  /**
   * 可选外部历史. 传入时会作为本轮模型上下文的一部分, 但服务端仍会维护 sessionId
   * 对应的内存上下文。
   */
  history?: ClientMessage[]
}

export interface DiarySummaryRequest {
  sessionId?: string
  history?: ClientMessage[]
}

export interface PersonaReply {
  persona: PersonaId
  displayName: string
  content: string
}

export interface DiaryChatResponse {
  sessionId: string
  replies: PersonaReply[]
}

export interface DiarySummaryResponse {
  sessionId: string
  title: string
  body: string
  summaryText: string
}

export interface ModelConfig {
  apiKey: string
  baseURL: string
  model: string
}

export type LetterAssistAction = 'continue' | 'polish'

export interface LetterAssistRequest {
  action: LetterAssistAction
  /** 当前信件正文草稿, 允许为空 (仅 continue 时可为空, polish 时必须有内容)。 */
  draft: string
}

export interface LetterAssistResponse {
  action: LetterAssistAction
  suggestion: string
}

export interface SessionMessage {
  speaker: ClientSpeaker
  content: string
  createdAt: string
}

export interface SessionState {
  id: string
  messages: SessionMessage[]
  createdAt: string
  updatedAt: string
}

export interface ModelMessage {
  role: 'system' | 'user' | 'assistant'
  content: string
}
