import Foundation

/// 本地 `agent-server` (Bun 服务) 的地址解析.
///
/// - 模拟器: 127.0.0.1 指向宿主 Mac, 默认值直接可用, 无需任何配置.
/// - 真机调试: 手机上的 127.0.0.1 指向手机自己, 必须换成 Mac 在局域网内可达的地址。
///   根目录 `run.sh device` 会在构建真机版本时, 通过 `AGENT_SERVER_BASE_URL` 编译设置
///   把 Mac 的 Bonjour 主机名 (例如 `http://MacBook-Pro.local:8787`) 写进 Info.plist,
///   这样即使 Mac 的局域网 IP 因为 DHCP 变化, 手机也能始终解析到正确地址, 不需要手动改代码。
enum AgentServerConfig {
    /// 兜底默认值: 模拟器场景下等价于宿主 Mac 自己。
    private static let fallbackBaseURL = URL(string: "http://127.0.0.1:8787")!

    static let baseURL: URL = resolveBaseURL()

    private static func resolveBaseURL() -> URL {
        if let raw = Bundle.main.object(forInfoDictionaryKey: "AgentServerBaseURL") as? String,
           !raw.isEmpty,
           !raw.hasPrefix("$("), // XcodeGen/Xcode 未展开变量时的占位符, 视为未配置
           let url = URL(string: raw) {
            return url
        }
        return fallbackBaseURL
    }

    /// 共享的 JSON POST 请求样板: 编码请求体, 发起请求, 校验 2xx 状态码, 解码响应。
    /// `DiaryAgentClient` / `LetterAgentClient` 都是同一个 agent-server 的客户端, 走同一套约定。
    static func post<Req: Encodable, Res: Decodable>(
        _ baseURL: URL,
        path: String,
        body: Req,
        timeout: TimeInterval
    ) async throws -> Res {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(Res.self, from: data)
    }
}
