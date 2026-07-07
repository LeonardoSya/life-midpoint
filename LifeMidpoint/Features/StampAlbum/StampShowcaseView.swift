import SwiftUI

struct StampShowcaseView: View {
    @Environment(\.dismiss) private var dismiss
    let stamp: StampInfo
    /// 是否已解锁/收集. 未解锁时邮票图仍可查看, 但以黑白呈现.
    var collected: Bool = true

    @State private var shareImage: UIImage?
    @State private var showShareSheet = false

    var body: some View {
        ZStack {
            background

            // 邮票内容垂直居中, 顶/底由 Spacer 平衡, actionLinks 紧贴
            // description, 不再被 Spacer 推到屏幕底部.
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                stampImage
                    .padding(.horizontal, 60)

                stampTitleSection
                    .padding(.top, 30)

                stampDescription
                    .padding(.top, 20)
                    .padding(.horizontal, 32)

                if collected {
                    actionLinks
                        .padding(.top, 28)
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        // 顶部按钮通过 safeAreaInset 自动紧贴 status bar 下沿,
        // 不再硬编码 padding(.top, 60) 导致不同设备视觉漂移.
        .safeAreaInset(edge: .top, spacing: 0) {
            navigationBar
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage {
                ActivityShareSheet(items: [shareImage])
            }
        }
    }

    /// 生成邮票分享图, 渲染完成后弹出系统分享面板 (自带"存储图像"选项).
    private func shareStamp() {
        Haptic.light()
        shareImage = renderShareImage(
            StampShareCardView(stamp: stamp, collectedCount: StampLibrary.totalCollected)
        )
        showShareSheet = shareImage != nil
    }

    private var background: some View {
        ZStack {
            Color.stampShowcaseBg
            LinearGradient(
                colors: [Color.stampShowcaseBlush.opacity(0.5),
                         Color.white.opacity(0.7),
                         Color.stampShowcaseBlush.opacity(0.6)],
                startPoint: .top, endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private var navigationBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.stampGold)
                    .padding(8)
            }
            Spacer()
            if collected {
                Button { shareStamp() } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.stampGold)
                        .padding(8)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var stampImage: some View {
        Image(stamp.imageName)
            .resizable()
            .scaledToFit()
            .saturation(collected ? 1.0 : 0.0)
            .shadow(color: .black.opacity(0.15), radius: 16, y: 10)
    }

    private var stampTitleSection: some View {
        VStack(spacing: 4) {
            Text(stamp.name)
                .font(AppFont.title(20))
                .foregroundStyle(Color.stampGold)
                .tracking(-0.14)

            Text(collected ? "你收集的第 \(StampLibrary.totalCollected) 个邮票" : "尚未解锁, 继续记录来收集它吧")
                .font(AppFont.body(10))
                .foregroundStyle(Color.stampGoldDeep)
        }
    }

    private var stampDescription: some View {
        Text(styledDescription(stamp.description))
            .multilineTextAlignment(.center)
            .lineSpacing(6)
    }

    /// 正文: 开头一句 (首个换行前) 用金色 16pt 点题, 其余黑色 14pt 叙述.
    private func styledDescription(_ text: String) -> AttributedString {
        var attr = AttributedString(text)
        attr.font = AppFont.body(14)
        attr.foregroundColor = .black
        if let newline = attr.characters.firstIndex(of: "\n") {
            let prefix = attr.startIndex..<newline
            attr[prefix].font = AppFont.body(16)
            attr[prefix].foregroundColor = Color.stampGold
        }
        return attr
    }

    private var actionLinks: some View {
        VStack(spacing: 8) {
            Button { } label: {
                Text("去写信")
                    .font(AppFont.body(12))
                    .foregroundStyle(Color.stampGoldLink)
                    .underline()
                    .tracking(-0.084)
            }

            Button { } label: {
                Text("查看当天日记")
                    .font(AppFont.body(12))
                    .foregroundStyle(Color.stampGoldLink)
                    .underline()
                    .tracking(-0.084)
            }
        }
    }
}
