import SwiftUI

// P6.26-P6.28 知识库 (2:23523)
struct KnowledgeBaseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedCategory: String
    /// 顶栏收藏图标: 切换"只看收藏"筛选.
    @State private var showBookmarkedOnly = false
    /// 已收藏文章 id 集合, 驱动列表筛选与每篇文章的收藏图标态.
    @State private var bookmarkedIds: Set<String> = []

    init(initialCategory: String? = nil) {
        let names = KnowledgeLibrary.categories.map(\.name)
        let initial = initialCategory.flatMap { names.contains($0) ? $0 : nil }
        _selectedCategory = State(initialValue: initial ?? names.first ?? "")
    }

    private var currentArticles: [KnowledgeArticle] {
        let base = KnowledgeLibrary.categories.first { $0.name == selectedCategory }?.articles ?? []
        guard showBookmarkedOnly else { return base }
        return base.filter { bookmarkedIds.contains($0.id) }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                categoryTabs

                if currentArticles.isEmpty {
                    emptyBookmarkNotice
                }

                ForEach(currentArticles) { article in
                    articleRow(article)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 84)
            .padding(.bottom, 40)
        }
        .background(Color.pageBackground.ignoresSafeArea())
        .onAppear { refreshBookmarks() }
        // 心境模块内的子页面统一由 `MainContainerView` 隐藏系统导航栏(避免与自定义返回按钮重复),
        // 所以这里不能依赖 `.toolbar` 放返回/收藏按钮 —— 必须用悬浮顶栏, 否则真机导航路径下会完全看不到.
        .toolbar(.hidden, for: .navigationBar)
        .overlay(alignment: .top) { topBar }
    }

    private var topBar: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea(edges: .top).frame(height: 84)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                }
                Spacer()
                Text("知识库")
                    .font(AppFont.title(20))
                Spacer()
                Button {
                    Haptic.selection()
                    showBookmarkedOnly.toggle()
                } label: {
                    Image(systemName: showBookmarkedOnly ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 16))
                        .foregroundStyle(showBookmarkedOnly ? Color.mindPrimary : Color.textPrimary)
                }
            }
            .padding(.horizontal, 34)
            .padding(.top, 18)
        }
    }

    private var emptyBookmarkNotice: some View {
        Text("还没有收藏这个分类下的文章")
            .font(AppFont.body(13))
            .foregroundStyle(Color.textSecondary.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
    }

    private func articleRow(_ article: KnowledgeArticle) -> some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(value: MindHomeView.MindRoute.psychologyCard(articleId: article.id)) {
                articleCard(article)
            }
            .buttonStyle(.plain)

            bookmarkToggle(for: article)
                .padding(16)
        }
    }

    private func bookmarkToggle(for article: KnowledgeArticle) -> some View {
        let isBookmarked = bookmarkedIds.contains(article.id)
        return Button {
            Haptic.light()
            MindRepository(context: modelContext).bookmark(articleKey: article.id)
            refreshBookmarks()
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .font(.system(size: 13))
                .foregroundStyle(isBookmarked ? Color.mindPrimary : Color.textSecondary.opacity(0.5))
                .frame(width: 28, height: 28)
                .background(Color.white.opacity(0.8), in: Circle())
        }
        .buttonStyle(.plain)
    }

    private func refreshBookmarks() {
        bookmarkedIds = Set(MindRepository(context: modelContext).allBookmarks().map(\.articleKey))
    }

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(KnowledgeLibrary.categories) { category in
                    Button {
                        Haptic.selection()
                        selectedCategory = category.name
                    } label: {
                        Text(category.name)
                            .font(AppFont.body(13))
                            .foregroundStyle(
                                selectedCategory == category.name ? .white : Color.textSecondary
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(selectedCategory == category.name ? Color.mindPrimary : Color.chipBackgroundIdle)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func articleCard(_ article: KnowledgeArticle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(article.title)
                .font(AppFont.title(16))
                .foregroundStyle(Color.textPrimary)
                .padding(.trailing, 32)

            Text(article.summary)
                .font(AppFont.body(12))
                .foregroundStyle(Color.textSecondary)
                .lineSpacing(4)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            HStack {
                Text(article.duration)
                    .font(AppFont.caption(10))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.chipBackgroundIdle, in: Capsule())

                Spacer()

                Text("阅读更多 →")
                    .font(AppFont.caption(11))
                    .foregroundStyle(Color.textSecondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
    }
}
