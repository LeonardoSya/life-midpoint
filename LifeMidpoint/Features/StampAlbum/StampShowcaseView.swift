import SwiftUI

struct StampShowcaseView: View {
    @Environment(\.dismiss) private var dismiss
    let stamp: StampInfo

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

                actionLinks
                    .padding(.top, 28)

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
            Button { } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.stampGold)
                    .padding(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }

    private var stampImage: some View {
        Image(stamp.imageName)
            .resizable()
            .scaledToFit()
            .shadow(color: .black.opacity(0.15), radius: 16, y: 10)
    }

    private var stampTitleSection: some View {
        VStack(spacing: 4) {
            Text(stamp.name)
                .font(AppFont.title(22))
                .foregroundStyle(Color.stampGold)
                .tracking(-0.14)

            Text("你收集的第 \(StampLibrary.totalCollected) 个邮票")
                .font(AppFont.body(10))
                .foregroundStyle(Color.stampGoldDeep)
        }
    }

    private var stampDescription: some View {
        Text(stamp.description)
            .font(AppFont.body(13))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .lineSpacing(6)
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
