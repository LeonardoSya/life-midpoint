import SwiftUI

/// 邮局首页的集邮册分类预览
struct StampCategoryCard: View {
    let name: String
    let images: [String]
    let collected: Int
    let total: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 3) {
                stampThumbnail(image: images[0], rotation: -4, dimmed: false)
                stampThumbnail(image: images[1], rotation: 6, dimmed: collected < 2)
            }
            .padding(.top, 16)
            .padding(.horizontal, 14)

            Text(name).bodyStyle(14)
                .padding(.top, 16)
                .padding(.horizontal, 16)

            Text("已收集 \(collected)/\(total) 张").secondaryStyle(10)
                .padding(.top, 4)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, minHeight: 143, alignment: .leading)
        .background(Color.postCardBg, in: RoundedRectangle(cornerRadius: 24))
    }

    private func stampThumbnail(image: String, rotation: Double, dimmed: Bool) -> some View {
        Group {
            if dimmed {
                Image(systemName: "lock.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.stampDashed)
                    .frame(width: 38, height: 46)
            } else {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 38, height: 46)
            }
        }
        .padding(5)
        .frame(width: 48, height: 56)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.stampDashed.opacity(0.3), style: StrokeStyle(lineWidth: 1, dash: [3, 2]))
        )
        .opacity(dimmed ? 0.55 : 1.0)
        .rotationEffect(.degrees(rotation))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}
