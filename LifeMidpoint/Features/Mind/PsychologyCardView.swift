import SwiftUI

// P6.25 心理卡牌展开页 (2:23268) — 知识卡片阅读页
struct PsychologyCardView: View {
    @Environment(\.dismiss) private var dismiss

    let article: KnowledgeArticle

    init(article: KnowledgeArticle = KnowledgeLibrary.article(for: KnowledgeLibrary.defaultArticleId)) {
        self.article = article
    }

    var body: some View {
        ZStack {
            immersiveBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 48) {
                    articleCard
                    feedbackSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 56)
                .padding(.bottom, 48)
            }
        }
        .overlay(alignment: .topLeading) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textPrimary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Immersive Background (浅色沉浸式渐变 + 柔光球)

    private var immersiveBackground: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0xF9F9F8), Color(hex: 0xFDFCF6), Color(hex: 0xF3F4F3)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            Ellipse()
                .fill(Color.mindAccent.opacity(0.5))
                .frame(width: 234, height: 442)
                .blur(radius: 60)
                .offset(x: -130, y: -170)
        }
        .ignoresSafeArea()
    }

    // MARK: - Article Knowledge Card

    private var articleCard: some View {
        VStack(alignment: .leading, spacing: 28) {
            Text(article.title)
                .font(AppFont.title(28))
                .foregroundStyle(Color.textPrimary)
                .tracking(-0.6)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .leading, spacing: 18) {
                ForEach(Array(article.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                    Text(paragraph)
                }
            }
            .font(AppFont.body(16))
            .foregroundStyle(Color.textSecondary)
            .lineSpacing(11)

            VStack(alignment: .leading, spacing: 12) {
                Rectangle()
                    .fill(Color(hex: 0xAFB3B2).opacity(0.18))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 4) {
                    Text("知识出处")
                        .font(AppFont.title(13))
                        .foregroundStyle(Color(hex: 0x777B7B))
                        .tracking(0.35)

                    Text(article.source)
                        .font(AppFont.body(12))
                        .foregroundStyle(Color(hex: 0xAFB3B2))
                        .lineSpacing(4)
                }
            }
            .padding(.top, 5)
        }
        .padding(.horizontal, 32)
        .padding(.top, 36)
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 40))
    }

    // MARK: - Subtle Feedback

    private var feedbackSection: some View {
        VStack(spacing: 4) {
            Text("太棒了！你又多了解了自己一点")
                .font(AppFont.body(14))
                .foregroundStyle(Color(hex: 0x777B7B))
                .multilineTextAlignment(.center)

            // 设计稿固定文案；阅读天数暂为占位，待接入真实阅读统计 (ArticleBookmark)。
            Text("你已记录阅读 7 天 ·")
                .font(AppFont.body(10))
                .foregroundStyle(Color(hex: 0xAFB3B2))
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}
