import Foundation

/// 写信页 AI 写作助手的本地 agent 后端客户端.
///
/// 复用 `agent-server` (同一个 Bun 服务, 地址解析见 `AgentServerConfig`) 下的
/// `/api/letter/assist` 接口, 支持"续写"和"润色"两种动作。
struct LetterAgentClient {
    static let shared = LetterAgentClient()

    var baseURL = AgentServerConfig.baseURL

    enum Action: String {
        case continueWriting = "continue"
        case polish
    }

    struct Response: Decodable {
        let action: String
        let suggestion: String
    }

    private struct RequestBody: Encodable {
        let action: String
        let draft: String
    }

    func assist(action: Action, draft: String) async throws -> String {
        let response: Response = try await AgentServerConfig.post(
            baseURL, path: "/api/letter/assist",
            body: RequestBody(action: action.rawValue, draft: draft),
            timeout: 45
        )
        return response.suggestion
    }
}
