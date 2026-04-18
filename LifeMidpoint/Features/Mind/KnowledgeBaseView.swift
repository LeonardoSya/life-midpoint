import SwiftUI

// P6.26-P6.28 知识库 (2:23523)
struct KnowledgeBaseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = "身体与情绪"

    private let categories = ["身体与情绪", "情绪急救", "关系与沟通", "自我成长", "白…"]

    private let articles: [(String, String, String)] = [
        ("潮热与情绪波动", "潮热时体温逐渐上升，会激活我们的交感神经系统……这不是你脾气变了，而是身体的\u{201C}应激开关\u{201D}被触发了。", "阅读时长 2 分钟"),
        ("隐性疲劳与精力管理", "更年期雌激素水平下降时，会影响深度睡眠的质量和时长。身体和大脑没有得到真正的休息，精力自然入不敷出。", "阅读时长 1 分钟"),
        ("脑雾与记忆力困扰", "很多更年期女性会经历暂时的记忆力变差和思维迟缓，这叫\u{201C}脑雾\u{201D}……这种状态通常是暂时的，会随着身体适应而缓解。", "阅读时长 1 分钟"),
        ("情绪与躯体化疼痛", "长期的情绪压力（焦虑、压抑）如果没有得到释放，会转化为躯体化症状存进肌肉里，表现为肩颈僵硬、深度酸痛。", "阅读时长 2 分钟"),
        ("心悸与焦虑反应", "更年期心悸多是激素波动影响对心跳的感知，或者是焦虑情绪引发的急性躯体反应。这种心悸通常是无害的，但感受上确实让人恐慌。", "阅读时长 2 分钟")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                categoryTabs
                    .padding(.top, 8)

                ForEach(articles, id: \.0) { article in
                    articleCard(title: article.0, summary: article.1, duration: article.2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .foregroundStyle(Color.textPrimary)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("知识库")
                    .font(AppFont.title(17))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { Haptic.selection() } label: {
                    Image(systemName: "bookmark")
                        .foregroundStyle(Color.textPrimary)
                }
            }
        }
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        Text(category)
                            .font(AppFont.body(13))
                            .foregroundStyle(
                                selectedCategory == category ? .white : Color.textSecondary
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(selectedCategory == category ? Color.mindPrimary : Color.chipBackgroundIdle)
                            )
                    }
                }
            }
        }
    }

    private func articleCard(title: String, summary: String, duration: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFont.title(16))
                .foregroundStyle(Color.textPrimary)

            Text(summary)
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(4)
                .lineLimit(3)

            HStack {
                Text(duration)
                    .font(AppFont.caption(10))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.chipBackgroundIdle, in: Capsule())

                Spacer()

                Button { } label: {
                    Text("阅读更多 →")
                        .font(AppFont.caption(11))
                        .foregroundStyle(Color.textSecondary)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}
