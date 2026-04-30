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
            VStack(alignment: .leading, spacing: 24) {
                if let onBackToDiary {
                    HStack {
                        ModuleHomeBackButton(action: onBackToDiary)
                        Spacer()
                    }
                }
                emotionSection
                personalSection
                systemSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("我的")
                    .font(AppFont.title(18))
            }
        }
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
        VStack(alignment: .leading, spacing: 16) {
            Text("情绪与体验")
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)

            VStack(spacing: 16) {
                HStack {
                    Text("时间氛围")
                        .font(AppFont.body(14))
                    Spacer()
                    Text("环境光感")
                        .font(AppFont.body(11))
                        .foregroundStyle(Color.textSecondary)
                }

                HStack(spacing: 8) {
                    ForEach(ambiances, id: \.self) { amb in
                        Button {
                            UserRepository(context: modelContext).updateAmbiance(amb)
                        } label: {
                            Text(amb)
                                .font(AppFont.body(12))
                                .foregroundStyle(settings.ambianceMode == amb ? .white : Color.textPrimary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    settings.ambianceMode == amb ? Color.textPrimary : Color.chipBackgroundIdle,
                                    in: Capsule()
                                )
                        }
                    }
                }

                HStack {
                    Text("白噪音")
                        .font(AppFont.body(14))
                    Spacer()
                    Text("专注伴奏")
                        .font(AppFont.body(11))
                        .foregroundStyle(Color.textSecondary)
                }

                HStack(spacing: 12) {
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
                                    .font(AppFont.body(10))
                            }
                            .foregroundStyle(settings.whiteNoiseMode == noise.name ? Color.textPrimary : Color.textSecondary)
                            .frame(width: 56, height: 56)
                            .background(
                                settings.whiteNoiseMode == noise.name ? Color.chipBackgroundSelected : Color.chipBackgroundAlt,
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                        }
                    }
                }
            }
            .padding(20)
            .background(.white, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    // MARK: - Personal & Records

    private var personalSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("个人与记录")
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)

            HStack(spacing: 16) {
                statCard(value: "\(diaryEntryCount)", label: "已写日记")
                statCard(value: "\(sentLetterCount)", label: "寄信")
                statCard(value: "\(activeDayCount)", label: "记录天数")
            }

            NavigationLink(value: SettingsRoute.weeklySummary) {
                HStack(spacing: 6) {
                    Text("我的周报")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textPrimary)
                    Text("2.1-2.7")
                        .font(AppFont.numeric(12))
                        .foregroundStyle(Color.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.textSecondary)
                }
                .padding(20)
                .background(Color.healthPinkLight, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
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

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppFont.title(24))
                .foregroundStyle(Color.textPrimary)
            Text(label)
                .font(AppFont.body(10))
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.healthPinkLight, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - System

    private var systemSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("系统")
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)

            VStack(spacing: 0) {
                settingsRow(icon: "bell", title: "通知设置")
                Divider().padding(.leading, 48)
                settingsRow(icon: "person", title: "账号管理")
                Divider().padding(.leading, 48)
                settingsRow(icon: "bubble.left", title: "客服与反馈")
                Divider().padding(.leading, 48)
                settingsRow(icon: "info.circle", title: "App 信息", trailing: "v2.4.0")
            }
            .background(.white, in: RoundedRectangle(cornerRadius: 24))
        }
    }

    private func settingsRow(icon: String, title: String, trailing: String? = nil) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.textSecondary)
                .frame(width: 24)

            Text(title)
                .font(AppFont.body(14))
                .foregroundStyle(Color.textPrimary)

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(AppFont.body(12))
                    .foregroundStyle(Color.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Color.textSecondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
