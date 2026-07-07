import Foundation

/// 日记页本地 agent 后端客户端.
///
/// 连接 `agent-server` 下的 Bun 服务 `/api/diary/chat`。地址解析见 `AgentServerConfig`
/// (模拟器默认 127.0.0.1 即可, 真机调试由构建脚本注入局域网地址)。
struct DiaryAgentClient {
    static let shared = DiaryAgentClient()

    var baseURL = AgentServerConfig.baseURL

    struct Reply: Decodable {
        let persona: String
        let displayName: String
        let content: String
    }

    struct Response: Decodable {
        let sessionId: String
        let replies: [Reply]
    }

    struct SummaryResponse: Decodable {
        let sessionId: String
        let title: String
        let body: String
        let summaryText: String
    }

    struct HistoryMessage: Encodable {
        let role: String
        let content: String
    }

    private struct RequestBody: Encodable {
        let sessionId: String?
        let message: String
    }

    private struct SummaryRequestBody: Encodable {
        let sessionId: String?
        let history: [HistoryMessage]
    }

    func send(message: String, sessionId: String?) async throws -> Response {
        try await AgentServerConfig.post(
            baseURL, path: "/api/diary/chat",
            body: RequestBody(sessionId: sessionId, message: message),
            timeout: 45
        )
    }

    func summarize(sessionId: String?, history: [HistoryMessage]) async throws -> SummaryResponse {
        try await AgentServerConfig.post(
            baseURL, path: "/api/diary/summary",
            body: SummaryRequestBody(sessionId: sessionId, history: history),
            timeout: 60
        )
    }
}
