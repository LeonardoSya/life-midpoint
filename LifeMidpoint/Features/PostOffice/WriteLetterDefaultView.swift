import SwiftUI

// P4.10 写信默认页 (2:19723)
struct WriteLetterDefaultView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var letterText = ""

    var body: some View {
        ZStack {
            paperBackground

            VStack(spacing: 0) {
                header

                topHint
                    .padding(.horizontal, 32)
                    .padding(.top, 32)

                Spacer()

                bottomToolbar
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
            .responsiveFill()
        }
    }

    private var paperBackground: some View {
        ZStack {
            Color.paperWarm

            // Subtle paper texture via blur
            Canvas { ctx, size in
                for _ in 0..<200 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let r = CGFloat.random(in: 0.5...1.5)
                    let path = Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r))
                    ctx.fill(path, with: .color(Color.brandMutedGold.opacity(0.15)))
                }
            }
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18))
                    .foregroundStyle(.black)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var topHint: some View {
        HStack(alignment: .top, spacing: 0) {
            Rectangle()
                .fill(Color.inkBrownDark)
                .frame(width: 2)
                .padding(.top, 2)
            Text("见字如面...分享一件开心或不开心的事情吧 😊")
                .font(AppFont.body(15))
                .foregroundStyle(Color.inkBrownDark)
                .padding(.leading, 12)
                .lineSpacing(4)
            Spacer()
        }
    }

    private var bottomToolbar: some View {
        HStack {
            HStack(spacing: 20) {
                toolbarButton(icon: "plus")
                toolbarButton(icon: "photo")
                toolbarButton(icon: "mic")
                toolbarButton(icon: "sparkles")
                toolbarButton(icon: "pencil.and.scribble")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.inkBrownLight, in: Capsule())

            Spacer()

            Button { } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.inkBrownLight, in: Circle())
            }
        }
    }

    private func toolbarButton(icon: String) -> some View {
        Button { } label: {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.white)
        }
    }
}

// P4.15 展示页面 (2:20177)
struct LetterShowcaseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.paperWarm.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text("3月24日 琥珀与猫")
                            .font(AppFont.body(13))
                            .foregroundStyle(Color.inkBrownDark)

                        VStack(alignment: .leading, spacing: 16) {
                            Text("今天的风很轻，我想把那些焦虑\n都吹散在云里...")
                                .font(AppFont.title(18))
                                .foregroundStyle(Color.textPrimary)
                                .lineSpacing(6)

                            Text("你今天还记得吗？早晨第一缕阳光透过窗纱的样子？我想告诉你，生活中那些看似微不足道的美好，恰恰是支撑我们度过每一天的力量。")
                                .font(AppFont.body(15))
                                .foregroundStyle(Color.textSecondary)
                                .lineSpacing(8)

                            Text("愿你今天也能感受到这些微小的美好。")
                                .font(AppFont.body(15))
                                .foregroundStyle(Color.textSecondary)
                                .lineSpacing(8)
                        }
                    }
                    .padding(32)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .shadow(color: .black.opacity(0.1), radius: 12, y: 8)
                    )
                    .padding(24)
                }

                Button { } label: {
                    Text("寄出")
                        .font(AppFont.body(16))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.inkBrownDeep, in: RoundedRectangle(cornerRadius: 28))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .responsiveFill()
        }
    }
}
