import SwiftUI
import SwiftData

struct PostOfficeView: View {
    var onBackToDiary: (() -> Void)? = nil
    var useOwnNavigationStack = true

    @State private var showWriteLetter = false
    /// 直接订阅最近 5 封信件 (用户每寄一封自动出现, 无需手动刷新).
    @Query(sort: \Letter.createdAt, order: .reverse)
    private var allLetters: [Letter]
    @State private var path: NavigationPath = {
        #if DEBUG
        let raw = ProcessInfo.processInfo.environment["DEBUG_PUSH_POSTOFFICE"] ?? ""
        var p = NavigationPath()
        switch raw {
        case "penPalList": p.append(PostOfficeRoute.penPalList)
        case "stampAlbum": p.append(PostOfficeRoute.stampAlbum)
        case "monthlyReport": p.append(PostOfficeRoute.monthlyReport)
        default: break
        }
        return p
        #else
        return NavigationPath()
        #endif
    }()

    var body: some View {
        if useOwnNavigationStack {
            NavigationStack(path: $path) {
                content
                    .navigationDestination(for: PostOfficeRoute.self) { route in
                        postOfficeDestination(route)
                    }
            }
        } else {
            content
        }
    }

    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                if let onBackToDiary {
                    HStack {
                        ModuleHomeBackButton(action: onBackToDiary)
                        Spacer()
                    }
                    .padding(.bottom, 4)
                }
                HeroWriteCard { showWriteLetter = true }
                NavigationLink(value: PostOfficeRoute.monthlyReport) {
                    SummaryBanner()
                }
                .buttonStyle(.plain)
                correspondenceSection
                stampCollectionSection
            }
            .padding(.horizontal, 24)
            .padding(.top, onBackToDiary == nil ? 56 : 28)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showWriteLetter) {
            WriteLetterView()
        }
    }

    @ViewBuilder
    func postOfficeDestination(_ route: PostOfficeRoute) -> some View {
        switch route {
        case .penPalList: PenPalListView()
        case .penPalDetail(let name): PenPalDetailView(name: name)
        case .stampAlbum: StampAlbumView()
        case .monthlyReport: MonthlyReportView()
        }
    }

    enum PostOfficeRoute: Hashable {
        case penPalList
        case penPalDetail(name: String)
        case stampAlbum
        case monthlyReport
    }

    /// 简洁的人类可读相对时间格式化, 用于卡片"2小时前"显示.
    private func relativeTime(_ date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.unitsStyle = .short
        return f.localizedString(for: date, relativeTo: Date())
    }

    // MARK: - Correspondence

    private var correspondenceSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .firstTextBaseline) {
                Text("信件往来").titleStyle(20)
                Spacer()
                NavigationLink(value: PostOfficeRoute.penPalList) {
                    Text("查看全部").secondaryStyle(12)
                }
            }

            // 优先显示真实历史信件; 用户尚未写过则回落到 demo 演示数据.
            let recent = Array(allLetters.prefix(5))
            if recent.isEmpty {
                ForEach(PostOfficeMock.recentLetters) { letter in
                    NavigationLink(value: PostOfficeRoute.penPalDetail(name: "未署名")) {
                        LetterCard(entry: letter)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                ForEach(recent) { letter in
                    NavigationLink(value: PostOfficeRoute.penPalDetail(name: letter.alias ?? "未署名")) {
                        LetterCard(entry: LetterEntry(
                            isFromMe: letter.direction == "sent",
                            time: relativeTime(letter.sentAt ?? letter.createdAt),
                            content: letter.body
                        ))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Stamp Collection

    private var stampCollectionSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            NavigationLink(value: PostOfficeRoute.stampAlbum) {
                HStack {
                    Text("我的集邮册").titleStyle(20)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 16) {
                NavigationLink(value: PostOfficeRoute.stampAlbum) {
                    StampCategoryCard(name: "候鸟归家",
                                      images: ["MigrationStamp18", "MigrationStamp19"],
                                      collected: 2, total: 12)
                }
                .buttonStyle(.plain)

                NavigationLink(value: PostOfficeRoute.stampAlbum) {
                    StampCategoryCard(name: "四时之花",
                                      images: ["FlowerStamp27", "FlowerStamp28"],
                                      collected: 1, total: 12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 32)
    }
}

// MARK: - Hero Write Card

private struct HeroWriteCard: View {
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(Color.postCream)
                .frame(width: 64, height: 64)
                .overlay(
                    Image("PostOfficeWriteIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22.5, height: 20)
                )

            Text("写一封信")
                .font(AppFont.title(24))
                .foregroundStyle(Color.textPrimary)
                .tracking(-0.6)
                .padding(.top, 24)

            Text("在这个喧嚣的世界，用文字寻找一方\n静谧的出口。")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(8.75)
                .padding(.top, 7)

            Button {
                Haptic.medium()
                onTap()
            } label: {
                Text("开始书写")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.postBrown)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.postCream, in: Capsule())
            }
            .padding(.top, 32)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: 32))
        .shadow(color: Color.textPrimary.opacity(0.06), radius: 16, y: 12)
    }
}

// MARK: - Summary Banner

private struct SummaryBanner: View {
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.postCream)
                .frame(width: 40, height: 72)
                .overlay(
                    Image("PostOfficeMailIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 16)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("邮局捷报").secondaryStyle(12).tracking(1.2)
                    Spacer()
                    Text("查看全部").secondaryStyle(12).tracking(0.6)
                }

                Group {
                    Text("本周你寄出了 ").foregroundStyle(Color.textPrimary) +
                    Text("1").foregroundStyle(Color.mindPrimary).bold() +
                    Text(" 封信，也收到了 ").foregroundStyle(Color.textPrimary) +
                    Text("2").foregroundStyle(Color.mindPrimary).bold() +
                    Text("封回应。\n一些情绪，仍在来去之间流动着。").foregroundStyle(Color.textPrimary)
                }
                .font(AppFont.body(15))
                .lineSpacing(6)
            }
        }
        .padding(20)
        .frame(height: 129)
        .background(.white, in: RoundedRectangle(cornerRadius: 24))
    }
}
