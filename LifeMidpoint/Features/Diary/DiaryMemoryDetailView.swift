import SwiftUI
import SwiftData

/// "查看完整回忆"详情页.
///
/// 从 `DiaryReviewView` 的当日卡片点击"查看完整回忆"进入, 展示:
/// - 完整日期 + 标题 + 当日情绪标签 (若有打卡)
/// - 完整日记正文 (不截断, 按段落展示)
/// - 当日"小确幸": 真实的信件送出/收到数与获得的邮票 (通过 `DailyMemoryAggregator` 聚合)
///
/// 对应 Figma 2:20750 "日记总结（有记录）": 日期 + 情绪标签 + 完整日记文本 + 分段。
struct DiaryMemoryDetailView: View {
    let date: Date
    let title: String
    let bodyText: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var highlights: DailyMemoryHighlights = .empty
    @State private var selectedStamp: StampInfo?

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    memoryCard
                }
                .padding(.horizontal, 28)
                .padding(.top, 64)
                .padding(.bottom, 48)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .topLeading) { backButton }
        .navigationDestination(item: $selectedStamp) { stamp in
            StampShowcaseView(stamp: stamp)
        }
        .onAppear {
            highlights = DailyMemoryAggregator(context: modelContext).highlights(for: date)
        }
    }

    private var backButton: some View {
        AppBackButton { dismiss() }
        .padding(.leading, 12)
        .padding(.top, 4)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(dayTitle(date))
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary.opacity(0.8))

            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(AppFont.title(24))
                    .foregroundStyle(Color.textPrimary)

                Spacer()

                if let moodLabel = highlights.moodLabel {
                    moodTag(moodLabel)
                }
            }
        }
        .padding(.top, 30)
    }

    private func moodTag(_ label: String) -> some View {
        HStack(spacing: 5) {
            if let icon = highlights.moodIcon {
                Image(systemName: icon)
                    .font(.system(size: 11))
            }
            Text(label)
                .font(AppFont.body(12))
        }
        .foregroundStyle(Color.textPrimary.opacity(0.75))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.mintMistBg.opacity(0.7), in: Capsule())
    }

    // MARK: - Memory Card

    private var memoryCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            bodyParagraphs

            cardDivider

            highlightsSection
        }
        .padding(28)
        .background(cardBackground)
        .shadow(color: Color.textPrimary.opacity(0.06), radius: 16, y: 12)
    }

    private var bodyParagraphs: some View {
        let paragraphs = bodyText
            .components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        return VStack(alignment: .leading, spacing: 14) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph)
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.textPrimary.opacity(0.86))
                    .lineSpacing(9)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var cardDivider: some View {
        Rectangle()
            .fill(Color.stampDashed.opacity(0.1))
            .frame(height: 1)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color.white.opacity(0.7))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
    }

    // MARK: - 今日小确幸

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("今日小确幸")
                .font(AppFont.body(11))
                .foregroundStyle(Color.textSecondary.opacity(0.58))

            HStack {
                Text("我的信件")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.textPrimary.opacity(0.72))
                Spacer()
                metaPill(icon: "envelope", text: "\(highlights.lettersSentCount)送出")
                metaPill(icon: "tray", text: "\(highlights.lettersReceivedCount)收到")
            }

            HStack(alignment: .center) {
                Text("我的邮票")
                    .font(AppFont.body(13))
                    .foregroundStyle(Color.textPrimary.opacity(0.72))
                Spacer()
                stampsPreview
            }
        }
    }

    @ViewBuilder
    private var stampsPreview: some View {
        if highlights.stampDefinitionIds.isEmpty {
            Text("今天还没有获得新的邮票")
                .font(AppFont.body(11))
                .foregroundStyle(Color.textSecondary.opacity(0.5))
        } else {
            HStack(spacing: 6) {
                ForEach(highlights.stampDefinitionIds.prefix(3), id: \.self) { id in
                    if let info = StampLibrary.info(for: id) {
                        Image(info.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 36)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Haptic.light()
                                selectedStamp = info
                            }
                    }
                }
            }
        }
    }

    private func metaPill(icon: String, text: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(text)
                .font(AppFont.body(10))
        }
        .foregroundStyle(Color.textSecondary.opacity(0.7))
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.72), in: Capsule())
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }

    // MARK: - Helpers

    private func dayTitle(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(comps.year ?? 2026)年\(comps.month ?? 1)月\(comps.day ?? 1)日"
    }
}
