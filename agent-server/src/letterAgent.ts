import type { LetterAssistRequest, LetterAssistResponse, ModelMessage } from './types'
import type { LlmClient } from './llmClient'

const SHARED_LETTER_RULES = `
你是 iOS 应用「人生中点」写信页里的写作助手。
用户在给"陌生人"或"未来/过去的自己"写一封手写感的信, 语气应该真诚、温暖、有生活细节, 像日记又像书信。
输出要求:
- 只输出信件正文本身, 不要加"好的""以下是"之类的开场白, 不要加引号或 Markdown。
- 不要输出 <think>、思考过程或任何元信息。
- 中文, 语气自然口语化, 避免空洞的鸡汤句。
`.trim()

function buildContinueMessages(draft: string): ModelMessage[] {
  const trimmed = draft.trim()
  return [
    {
      role: 'system',
      content: `${SHARED_LETTER_RULES}

任务: 顺着用户已经写下的内容, 继续往下写 1 到 3 句, 保持人称、语气和情绪的连贯性。
只输出要新增的续写内容, 不要重复用户已经写过的文字。`,
    },
    {
      role: 'user',
      content: trimmed
        ? `已经写下的内容:\n${trimmed}\n\n请顺着往下续写。`
        : '我还没想好怎么开头, 请给我写一句自然的开头, 帮我打开话头。',
    },
  ]
}

function buildPolishMessages(draft: string): ModelMessage[] {
  return [
    {
      role: 'system',
      content: `${SHARED_LETTER_RULES}

任务: 润色用户这段草稿——让语言更顺、更有画面感, 但不要改变原意, 不要大幅增删内容, 长度与原文接近。`,
    },
    {
      role: 'user',
      content: `请润色这段草稿:\n${draft.trim()}`,
    },
  ]
}

export async function handleLetterAssist(
  client: LlmClient,
  input: LetterAssistRequest,
): Promise<LetterAssistResponse> {
  const messages = input.action === 'polish'
    ? buildPolishMessages(input.draft)
    : buildContinueMessages(input.draft)

  const suggestion = await client.chat(messages, { compact: false, thinking: false })

  return { action: input.action, suggestion }
}
