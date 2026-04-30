import Foundation

/// 日记页本地 agent 后端客户端.
///
/// 默认连接 `http://127.0.0.1:8787/api/diary/chat`, 也就是
/// `agent-server` 下的 Bun 服务。iOS Simulator 中 127.0.0.1 指向宿主 Mac,
/// 真机调试时需要把 `baseURL` 改成 Mac 局域网 IP。
struct DiaryAgentClient {
    static let shared = DiaryAgentClient()

    var baseURL = URL(string: "http://127.0.0.1:8787")!

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
        var request = URLRequest(url: baseURL.appending(path: "/api/diary/chat"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 45
        request.httpBody = try JSONEncoder().encode(RequestBody(sessionId: sessionId, message: message))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(Response.self, from: data)
    }

    func summarize(sessionId: String?, history: [HistoryMessage]) async throws -> SummaryResponse {
        var request = URLRequest(url: baseURL.appending(path: "/api/diary/summary"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        request.httpBody = try JSONEncoder().encode(SummaryRequestBody(sessionId: sessionId, history: history))

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(SummaryResponse.self, from: data)
    }
}
