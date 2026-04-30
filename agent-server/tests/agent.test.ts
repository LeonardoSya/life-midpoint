import { describe, expect, test } from 'bun:test'
import { compactOneSentence } from '../src/minimaxClient'
import { handleDiaryChat, handleDiarySummary } from '../src/diaryAgent'
import { parseDiaryChatRequest, parseDiarySummaryRequest, readJson } from '../src/validation'
import type { ModelMessage } from '../src/types'

class FakeClient {
  calls: ModelMessage[][] = []

  async chat(messages: ModelMessage[]): Promise<string> {
    this.calls.push(messages)
    if (messages.at(-1)?.content.includes('日记总结')) {
      return '{"moodTitle":"疲惫但平静的晴天","body":"今天我有点累，也有一点说不清的安静。"}'
    }
    const system = messages[0]?.content ?? ''
    return system.includes('老奶奶')
      ? '奶奶：先让自己靠一靠，累的时候不用急着把一切做好。'
      : '小女孩：那我们先坐一会儿，好不好？'
  }
}

describe('compactOneSentence', () => {
  test('removes persona prefix and keeps one sentence', () => {
    expect(compactOneSentence('奶奶：先喝口热水。第二句不要出现。')).toBe('先喝口热水。')
  })

  test('strips think tags', () => {
    expect(compactOneSentence('<think>用户很累</think>我听见你这份说不清的疲惫了。')).toBe('我听见你这份说不清的疲惫了。')
  })
})

describe('parseDiaryChatRequest', () => {
  test('validates message', () => {
    expect(() => parseDiaryChatRequest({ message: '' })).toThrow()
    expect(parseDiaryChatRequest({ message: '  今天有点累  ' }).message).toBe('今天有点累')
  })

  test('rejects oversized body even without content-length', async () => {
    const large = JSON.stringify({ message: 'x'.repeat(70_000) })
    const request = new Request('http://local.test', { method: 'POST', body: large })
    await expect(readJson(request)).rejects.toThrow('Request body too large')
  })

  test('validates summary request', () => {
    expect(() => parseDiarySummaryRequest({})).toThrow()
    expect(parseDiarySummaryRequest({ sessionId: 'abc' }).sessionId).toBe('abc')
  })
})

describe('handleDiaryChat', () => {
  test('generates grandma and girl replies with shared user context', async () => {
    const client = new FakeClient()
    const result = await handleDiaryChat(client as never, {
      message: '我今天有点累',
      history: [{ role: 'user', content: '昨天也没睡好' }],
    })

    expect(result.sessionId.length).toBeGreaterThan(0)
    expect(result.replies.map((r) => r.persona)).toEqual(['grandma', 'girl'])
    expect(client.calls).toHaveLength(2)
    expect(client.calls[0].some((m) => m.content.includes('昨天也没睡好'))).toBe(true)
    expect(client.calls[1].some((m) => m.content.includes('我今天有点累'))).toBe(true)
  })

  test('generates diary summary', async () => {
    const client = new FakeClient()
    const result = await handleDiarySummary(client as never, {
      history: [{ role: 'user', content: '我今天很累' }],
    })
    expect(result.title).toBe('疲惫但平静的晴天')
    expect(result.summaryText).toContain('疲惫但平静的晴天')
    expect(result.summaryText).toContain('今天我有点累')
  })

  test('parses partial diary summary json from model output', async () => {
    class PartialJsonClient {
      async chat() {
        return '{"moodTitle":"沉沉的夜与轻轻的拥抱","body":"今天真的很累，从身体到心里都像是被什么压着。'
      }
    }

    const result = await handleDiarySummary(new PartialJsonClient() as never, {
      history: [{ role: 'user', content: '我今天很累' }],
    })

    expect(result.title).toBe('沉沉的夜与轻轻的拥抱')
    expect(result.body).toContain('今天真的很累')
  })
})
