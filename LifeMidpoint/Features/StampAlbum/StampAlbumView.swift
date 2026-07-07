import SwiftUI

/// 邮票网格中被选中的一枚, 附带是否已解锁的信息, 以便详情页决定是否展示黑白图.
private struct StampSelection: Identifiable, Hashable {
    let stamp: StampInfo
    let collected: Bool
    var id: String { stamp.id }
}

struct StampAlbumView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStamp: StampSelection?
    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroSection
                stampSeriesList
                    .padding(.top, 24)
                continuedFooter
                    .padding(.top, 32)
                    .padding(.bottom, 60)
            }
            .frame(maxWidth: .infinity)
        }
        .background(
            LinearGradient(
                colors: [Color.stampAlbumGradTop, Color.pageBackground],
                startPoint: .top, endPoint: .bottom
            ).ignoresSafeArea()
        )
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) { topBar }
        .navigationDestination(item: $selectedStamp) { selection in
            StampShowcaseView(stamp: selection.stamp, collected: selection.collected)
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ActivityShareSheet(items: [shareImage])
            }
        }
    }

    private func shareCollection() {
        Haptic.light()
        shareImage = renderShareImage(StampCollectionShareCardView(collectedCount: StampLibrary.totalCollected))
        showShareSheet = shareImage != nil
    }

    private var topBar: some View {
        ZStack {
            Text("我的集邮册")
                .font(AppFont.body(18))
                .foregroundStyle(Color.textPrimary)
            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(.plain)
                Spacer()
                Button { shareCollection() } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.textPrimary)
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(Color.stampAlbumGradTop.opacity(0.0))
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        ZStack {
            // 设计稿: 卡片内极淡的有机绿色辉光 (2:19553 #536443 @0.05)
            Circle()
                .fill(Color.mindPrimary.opacity(0.05))
                .frame(width: 280, height: 280)
                .blur(radius: 32)
                .opacity(0.4)

            VStack(spacing: 0) {
                Text("你已经收集了")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.textSecondary)

                Text("\(StampLibrary.totalCollected)")
                    .font(AppFont.title(110))
                    .foregroundStyle(Color.mindPrimary)
                    .padding(.top, -8)

                Text("张邮票")
                    .font(AppFont.title(18))
                    .foregroundStyle(Color.textSecondary)
                    .tracking(1.8)
                    .padding(.top, -14)

                VStack(spacing: 16) {
                    Text("今天还没有新的记录")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary)

                    VStack(spacing: 8) {
                        linkButton("→ 写一封信")
                        linkButton("→ 写篇日记")
                    }
                }
                .padding(.top, 40)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 430)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.pageBackground)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
        .padding(.horizontal, 21)
        .padding(.top, 12)
    }

    private func linkButton(_ text: String) -> some View {
        Button { } label: {
            Text(text)
                .font(AppFont.body(14))
                .foregroundStyle(Color.mindPrimary)
        }
    }

    // MARK: - Series List

    private var stampSeriesList: some View {
        VStack(spacing: 32) {
            ForEach(StampLibrary.allSeries) { series in
                stampSeriesRow(series)
            }
        }
        .padding(.horizontal, 16)
    }

    private func stampSeriesRow(_ series: StampSeriesData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(series.name)
                        .font(AppFont.title(20))
                        .foregroundStyle(Color.mindPrimary)
                        .tracking(-0.5)
                    Text(series.subtitle)
                        .font(AppFont.body(12))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    Text("\(series.collectedCount) / \(series.totalCount)")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.mindPrimary)
                    progressBar(collected: series.collectedCount, total: series.totalCount)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -8) {
                    ForEach(Array(series.stamps.enumerated()), id: \.element.id) { idx, stamp in
                        let collected = idx < series.collectedCount
                        stampCard(stamp: stamp, collected: collected, rotation: rotationForIndex(idx))
                            .onTapGesture {
                                Haptic.light()
                                selectedStamp = StampSelection(stamp: stamp, collected: collected)
                            }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
        }
    }

    private func progressBar(collected: Int, total: Int) -> some View {
        let ratio: CGFloat = total > 0 ? min(1.0, CGFloat(collected) / CGFloat(total)) : 0
        return ZStack(alignment: .leading) {
            Capsule().fill(Color(hex: 0xECEEED))
            Capsule().fill(Color.mindPrimary).frame(width: 96 * ratio)
        }
        .frame(width: 96, height: 6)
    }

    private func rotationForIndex(_ i: Int) -> Double {
        let rotations: [Double] = [-4, 6, -3, 4, -2, 5, -5, 3]
        return rotations[i % rotations.count]
    }

    private func stampCard(stamp: StampInfo, collected: Bool, rotation: Double) -> some View {
        Image(stamp.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 130)
            .opacity(collected ? 1.0 : 0.25)
            .saturation(collected ? 1.0 : 0.0)
            .rotationEffect(.degrees(rotation))
            .shadow(color: .black.opacity(0.1), radius: 3, y: 2)
    }

    // MARK: - Footer

    private var continuedFooter: some View {
        Text("- 待 续 -")
            .font(AppFont.body(12))
            .foregroundStyle(Color.textPrimary)
            .tracking(-0.084)
    }
}
