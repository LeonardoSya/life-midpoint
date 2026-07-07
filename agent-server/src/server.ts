import { getServerHost, getServerPort, loadModelConfig } from './config'
import { createHandler } from './http'
import { LlmClient } from './llmClient'

const config = await loadModelConfig()
const client = new LlmClient(config)
const port = getServerPort()
const host = getServerHost()

Bun.serve({
  port,
  hostname: host,
  fetch: createHandler(client),
})

console.log(`[agent-server] listening on http://${host}:${port} (AGENT_HOST=${host})`)
console.log(`[agent-server] model=${config.model} baseURL=${config.baseURL}`)
