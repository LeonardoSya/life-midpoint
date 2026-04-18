import SwiftUI

struct DiaryReviewView: View {
    let hasRecords: Bool

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            if hasRecords {
                DiaryReviewWithRecordsView()
            } else {
                DiaryReviewEmptyView()
            }
        }
    }
}

// MARK: - With Records (2:20750)

private struct DiaryReviewWithRecordsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("3月24日")
                    .font(AppFont.title(28))
                    .foregroundStyle(Color.textPrimary)

                HStack(spacing: 8) {
                    emotionTag("平静", color: Color.mindMuted)
                    emotionTag("疲惫", color: Color.diarySandWarm)
                    emotionTag("希望", color: Color.summaryDecoration)
                }

                Divider().padding(.vertical, 8)

                Text("今天才意识到，最近其实一直有点乱。晚上躺下来之后，脑子就停不下来，一会儿想白天的事情，一会儿又想到那些没做完的，还有家里的事。有些事情其实不算很大，但就是会反复想。越想越清醒，反而更睡不着。")
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(8)

                Text("其实身体已经很困了，但就是没办法真的放松下来。第二天起来也没什么精神，整个人有点懵。好像一直在转，没有真的停下来过。现在这样想一想，其实是有点累了。")
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(8)

                Text("如果是小时候的我，大概不会这样。她可能只会觉得\u{201C}有点困\u{201D}，然后就去睡了。对她来说，一切都简单一点。")
                    .font(AppFont.body(15))
                    .foregroundStyle(Color.textPrimary)
                    .lineSpacing(8)
            }
            .padding(24)
        }
    }

    private func emotionTag(_ text: String, color: Color) -> some View {
        Text(text)
            .font(AppFont.body(11))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color, in: Capsule())
    }
}

// MARK: - Empty State (2:20901)

private struct DiaryReviewEmptyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundStyle(Color.brandMutedGold)

            VStack(spacing: 8) {
                Text("今天还没有记录")
                    .font(AppFont.title(20))
                    .foregroundStyle(Color.textPrimary)

                Text("坐在沙滩上，和他们说说话吧。")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.textSecondary)
            }

            Button { dismiss() } label: {
                Text("开始记录")
                    .font(AppFont.body(14))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.brandMutedGold, in: Capsule())
            }
            .padding(.top, 16)
            Spacer()
        }
    }
}
