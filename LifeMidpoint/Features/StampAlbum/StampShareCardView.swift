import SwiftUI

/// 单张邮票的分享卡片, 用 `ImageRenderer` 离屏渲染成图片后交给系统分享面板.
/// 系统分享面板自带"存储图像"选项, 用户可以自行选择是否保存到相册, 或分享到其他 App.
struct StampShareCardView: View {
    let stamp: StampInfo
    let collectedCount: Int

    var body: some View {
        VStack(spacing: 18) {
            Image(stamp.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 240)
                .shadow(color: .black.opacity(0.15), radius: 16, y: 10)

            VStack(spacing: 4) {
                Text(stamp.name)
                    .font(AppFont.title(22))
                    .foregroundStyle(Color.stampGold)
                    .tracking(-0.14)
                Text("我收集的第 \(collectedCount) 个邮票")
                    .font(AppFont.body(11))
                    .foregroundStyle(Color.stampGoldDeep)
            }

            Text(stamp.description)
                .font(AppFont.body(13))
                .foregroundStyle(Color.black.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .padding(.horizontal, 26)

            Spacer(minLength: 4)

            watermark
        }
        .padding(.top, 40)
        .padding(.bottom, 28)
        .frame(width: 320, height: 480)
        .background(cardBackground)
    }

    private var watermark: some View {
        HStack(spacing: 6) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 10))
            Text("生命的中点")
                .font(AppFont.body(11))
                .tracking(1)
        }
        .foregroundStyle(Color.stampGoldDeep.opacity(0.6))
    }

    private var cardBackground: some View {
        ZStack {
            Color.stampShowcaseBg
            LinearGradient(
                colors: [Color.stampShowcaseBlush.opacity(0.5),
                         Color.white.opacity(0.7),
                         Color.stampShowcaseBlush.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }
}

/// 集邮册总览的分享卡片 (无具体邮票时, 展示已收集总数).
struct StampCollectionShareCardView: View {
    let collectedCount: Int

    var body: some View {
        VStack(spacing: 6) {
            Text("我已经收集了")
                .font(AppFont.body(14))
                .foregroundStyle(Color.textSecondary)
            Text("\(collectedCount)")
                .font(AppFont.title(96))
                .foregroundStyle(Color.mindPrimary)
            Text("张邮票")
                .font(AppFont.title(18))
                .foregroundStyle(Color.textSecondary)
                .tracking(1.8)
            Spacer(minLength: 12)
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill").font(.system(size: 10))
                Text("生命的中点").font(AppFont.body(11)).tracking(1)
            }
            .foregroundStyle(Color.mindPrimary.opacity(0.6))
        }
        .padding(.top, 48)
        .padding(.bottom, 28)
        .frame(width: 320, height: 400)
        .background(Color.pageBackground)
    }
}

/// 将任意 SwiftUI 视图渲染成 `UIImage`, 用于生成分享图.
@MainActor
func renderShareImage<V: View>(_ view: V, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
    let renderer = ImageRenderer(content: view)
    renderer.scale = scale
    return renderer.uiImage
}

/// 包装系统分享面板 (`UIActivityViewController`), 分享图片时系统会自带"存储图像"
/// (保存到相册)、AirDrop、发送给朋友等选项, 交由用户自行选择.
struct ActivityShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
