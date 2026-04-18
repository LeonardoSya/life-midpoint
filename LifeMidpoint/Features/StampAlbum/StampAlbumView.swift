import SwiftUI

struct StampAlbumView: View {
    @State private var selectedStamp: StampInfo?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroSection
                stampSeriesList
                    .padding(.top, 24)
                searchButton
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("我的集邮册")
                    .font(AppFont.body(16))
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .navigationDestination(item: $selectedStamp) { stamp in
            StampShowcaseView(stamp: stamp)
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white.opacity(0.3))
                    .blur(radius: 20)
                    .frame(width: 320, height: 320)

                VStack(spacing: 0) {
                    Text("你已经收集了")
                        .font(AppFont.body(14))
                        .foregroundStyle(Color.textSecondary)

                    Text("\(StampLibrary.totalCollected)")
                        .font(AppFont.title(96))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.top, -8)

                    Text("张邮票")
                        .font(AppFont.title(20))
                        .foregroundStyle(Color.textPrimary)
                        .padding(.top, -12)

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
            .frame(height: 430)
            .padding(.horizontal, 21)
        }
    }

    private func linkButton(_ text: String) -> some View {
        Button { } label: {
            Text(text)
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)
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
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(series.name)
                        .font(AppFont.title(20))
                        .foregroundStyle(Color.textPrimary)
                    Text(series.subtitle)
                        .font(AppFont.body(12))
                        .foregroundStyle(Color.textSecondary)
                }
                Spacer()
                Text("\(series.collectedCount) / \(series.totalCount)")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.textSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -8) {
                    ForEach(Array(series.stamps.enumerated()), id: \.element.id) { idx, stamp in
                        stampCard(
                            stamp: stamp,
                            collected: idx < series.collectedCount,
                            rotation: rotationForIndex(idx)
                        )
                        .onTapGesture {
                            if idx < series.collectedCount {
                                Haptic.light()
                                selectedStamp = stamp
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
            }
        }
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

    // MARK: - Search

    private var searchButton: some View {
        Button { Haptic.light() } label: {
            HStack(spacing: 4) {
                Image(systemName: "magnifyingglass").font(.system(size: 12))
                Text("搜索")
                    .font(AppFont.body(14))
            }
            .foregroundStyle(Color.textSecondary)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Capsule().stroke(Color.borderLight, lineWidth: 1))
        }
    }
}
