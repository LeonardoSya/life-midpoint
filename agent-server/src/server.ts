import { getServerPort, loadModelConfig } from './config'
import { createHandler } from './http'
import { MiniMaxClient } from './minimaxClient'

const config = await loadModelConfig()
const client = new MiniMaxClient(config)
const port = getServerPort()

Bun.serve({
  port,
  hostname: '127.0.0.1',
  fetch: createHandler(client),
})

console.log(`[agent-server] listening on http://127.0.0.1:${port}`)
console.log(`[agent-server] model=${config.model} baseURL=${config.baseURL}`)
