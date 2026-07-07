import SwiftUI
import SwiftData

struct SettingsView: View {
    var onBackToDiary: (() -> Void)? = nil
    var useOwnNavigationStack = true

    @Environment(\.modelContext) private var modelContext
    @StateObject private var audio = AudioPlayer.shared
    @Query private var settingsRows: [AppSettings]
    @Query private var profiles: [UserProfile]
    @Query private var diarySessions: [DiarySession]
    @Query(sort: \Letter.createdAt, order: .reverse)
    private var allLetters: [Letter]
    @Query private var allDiaryMessages: [DiaryMessage]

    /// 偏好绑定: 直接读写 SwiftData (跨启动持久化).
    private var settings: AppSettings {
        if let s = settingsRows.first { return s }
        return AppDatabase.settings(in: modelContext)
    }

    @State private var path: NavigationPath = {
        #if DEBUG
        let raw = ProcessInfo.processInfo.environment["DEBUG_PUSH_PROFILE"] ?? ""
        var p = NavigationPath()
        switch raw {
        case "weeklySummary": p.append(SettingsRoute.weeklySummary)
        case "stampAlbum": p.append(SettingsRoute.stampAlbum)
        default: break
        }
        return p
        #else
        return NavigationPath()
        #endif
    }()

    private let ambiances = ["自动", "白天", "黄昏", "夜晚"]
    private let noises: [(name: String, icon: String, file: String?)] = [
        ("关闭", "speaker.slash.fill", nil),
        ("海浪", "water.waves", AudioAssets.whiteNoiseWaves),
        ("风", "wind", AudioAssets.whiteNoiseWind),
        ("雨", "cloud.drizzle", AudioAssets.whiteNoiseRain)
    ]

    var body: some View {
        if useOwnNavigationStack {
            NavigationStack(path: $path) {
                content
                    .navigationDestination(for: SettingsRoute.self) { route in
                        settingsDestination(route)
                    }
            }
        } else {
            content
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                header
                emotionSection
                personalSection
                systemSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
    }

    /// 页内标题 "我的". 系统导航栏被全局隐藏, 故 principal 标题不可见,
    /// 这里用居中的自定义标题呈现, 左侧保留返回按钮.
    private var header: some View {
        ZStack {
            Text("我的")
                .font(AppFont.title(20))
                .foregroundStyle(Color.textPrimary)
            if let onBackToDiary {
                HStack {
                    ModuleHomeBackButton(action: onBackToDiary)
                    Spacer()
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// 分组小标题 (思源宋体 Bold 14 + 字距).
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(AppFont.title(14))
            .tracking(1.4)
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, 8)
    }

    @ViewBuilder
    func settingsDestination(_ route: SettingsRoute) -> some View {
        switch route {
        case .weeklySummary: WeeklySummaryView(variant: 0)
        case .stampAlbum: StampAlbumView()
        }
    }

    enum SettingsRoute: Hashable {
        case weeklySummary
        case stampAlbum
    }

    // MARK: - Emotion & Experience

    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            sectionHeader("情绪与体验")

            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    HStack {
                        Text("时间氛围")
                            .font(AppFont.body(16))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text("环境光感")
                            .font(AppFont.body(12))
                            .foregroundStyle(Color.textSecondary)
                    }

                    HStack(spacing: 8) {
                        ForEach(ambiances, id: \.self) { amb in
                            Button {
                                UserRepository(context: modelContext).updateAmbiance(amb)
                            } label: {
                                Text(amb)
                                    .font(AppFont.body(14))
                                    .foregroundStyle(settings.ambianceMode == amb ? Color(hex: 0x465736) : Color.textSecondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(
                                        settings.ambianceMode == amb ? Color(hex: 0xF8E4E1) : Color.clear,
                                        in: Capsule()
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(6)
                    .background(Color(hex: 0xF3F4F3), in: Capsule())
                }

                VStack(spacing: 16) {
                    HStack {
                        Text("白噪音")
                            .font(AppFont.body(16))
                            .foregroundStyle(Color.textSecondary)
                        Spacer()
                        Text("专注伴奏")
                            .font(AppFont.body(12))
                            .foregroundStyle(Color.textSecondary)
                    }

                    HStack(spacing: 8) {
                        ForEach(noises, id: \.name) { noise in
                            Button {
                                Haptic.selection()
                                UserRepository(context: modelContext).updateWhiteNoise(noise.name)
                                if let file = noise.file {
                                    audio.play(file: file, channel: .ambient, loop: true, volume: 0.6)
                                } else {
                                    audio.stop(channel: .ambient)
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: noise.icon)
                                        .font(.system(size: 16))
                                    Text(noise.name)
                                        .font(AppFont.body(12))
                                }
                                .foregroundStyle(Color.textSecondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(Color(hex: 0xF3F4F3), in: RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(settings.whiteNoiseMode == noise.name ? Color(hex: 0xF8E4E1) : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
            )
        }
    }

    // MARK: - Personal & Records

    private var personalSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            sectionHeader("个人与记录")

            VStack(spacing: 6) {
                HStack(spacing: 16) {
                    NavigationLink(value: DiaryView.DiaryRoute.review(hasRecords: diaryEntryCount > 0)) {
                        statCard(value: "\(diaryEntryCount)", label: "已写日记")
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: PostOfficeView.PostOfficeRoute.penPalList) {
                        statCard(value: "\(sentLetterCount)", label: "写信")
                    }
                    .buttonStyle(.plain)

                    NavigationLink(value: SettingsRoute.weeklySummary) {
                        statCard(value: "\(activeDayCount)", label: "记录天数")
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink(value: SettingsRoute.weeklySummary) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("我的周报")
                                .font(AppFont.body(20))
                                .foregroundStyle(Color.textSecondary)
                            Text("2.1-2.7")
                                .font(AppFont.numeric(12))
                                .foregroundStyle(Color.textPrimary)
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.textSecondary.opacity(0.6))
                        }

                        Text("过去一周，你的情绪呈平稳上升趋势，早晨的呼吸练习显著降低了心率峰值。")
                            .font(AppFont.body(13))
                            .foregroundStyle(Color.textSecondary)
                            .lineSpacing(4)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        weeklyMiniChart
                            .frame(height: 52)

                        HStack(spacing: 20) {
                            weeklyMiniStat(icon: "moon.fill", value: "7h 45m", label: "睡眠时长")
                            weeklyMiniStat(icon: "heart.fill", value: "64 bpm", label: "平均心率")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(Color.summaryPink, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - 派生统计 (从 SwiftData 实时聚合)

    /// "已写日记" = 至少含有一条用户消息的 session 数量.
    private var diaryEntryCount: Int {
        diarySessions.filter { s in s.messages.contains(where: { $0.isFromUser }) }.count
    }

    /// "寄信" = status == sent 的信件数.
    private var sentLetterCount: Int {
        allLetters.filter { $0.status == "sent" }.count
    }

    /// "记录天数" = 用户消息日期 ∪ 寄信日期 的去重天数.
    private var activeDayCount: Int {
        let cal = Calendar.current
        var days: Set<Date> = []
        for m in allDiaryMessages where m.isFromUser {
            days.insert(cal.startOfDay(for: m.sentAt))
        }
        for l in allLetters where l.status == "sent" {
            days.insert(cal.startOfDay(for: l.sentAt ?? l.createdAt))
        }
        return days.count
    }

    /// "我的周报"卡片里的缩略趋势图, 与 WeeklySummaryView 详情页用同一套配色和 mock 数据点,
    /// 让用户点进去之前就能"预览"一眼本周走势, 而不是空空的一张卡片.
    private var weeklyMiniChart: some View {
        Canvas { ctx, size in
            let mood: [CGFloat] = [0.3, 0.4, 0.5, 0.45, 0.6, 0.7, 0.75]
            let sleep: [CGFloat] = [0.5, 0.4, 0.6, 0.5, 0.55, 0.5, 0.55]
            let heartRate: [CGFloat] = [0.35, 0.3, 0.4, 0.35, 0.3, 0.32, 0.28]
            let step = size.width / CGFloat(mood.count - 1)

            func linePath(_ values: [CGFloat]) -> Path {
                var path = Path()
                for (i, v) in values.enumerated() {
                    let point = CGPoint(x: CGFloat(i) * step, y: size.height * (1 - v))
                    if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
                }
                return path
            }

            ctx.stroke(linePath(heartRate), with: .color(Color(hex: 0xF5A623)),
                       style: StrokeStyle(lineWidth: 1.2, dash: [3, 2]))
            ctx.stroke(linePath(sleep), with: .color(Color(hex: 0xFFCCC5)), lineWidth: 1.6)
            ctx.stroke(linePath(mood), with: .color(Color(hex: 0x556350)), lineWidth: 2)
        }
    }

    private func weeklyMiniStat(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Color(hex: 0x495745))
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(AppFont.numeric(13))
                    .foregroundStyle(Color.textPrimary)
                Text(label)
                    .font(AppFont.caption(10))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFont.title(24))
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(AppFont.body(10))
                .tracking(-0.5)
                .foregroundStyle(Color.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.healthPinkLight, in: RoundedRectangle(cornerRadius: 24))
    }

    // MARK: - System

    private var systemSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            sectionHeader("系统")

            VStack(spacing: 0) {
                settingsRow(icon: "bell", title: "通知设置")
                Divider().padding(.horizontal, 20)
                settingsRow(icon: "person", title: "账号管理")
                Divider().padding(.horizontal, 20)
                settingsRow(icon: "bubble.left", title: "客服与反馈")
                Divider().padding(.horizontal, 20)
                settingsRow(icon: "info.circle", title: "App 信息", trailing: "v2.4.0")
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
        }
    }

    private func settingsRow(icon: String, title: String, trailing: String? = nil) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 24)

            Text(title)
                .font(AppFont.body(16))
                .foregroundStyle(Color.textSecondary)

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(AppFont.body(12))
                    .underline()
                    .foregroundStyle(Color.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
}
