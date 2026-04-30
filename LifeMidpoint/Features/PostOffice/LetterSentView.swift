import SwiftUI

// P4.16 信件已寄出确认 (2:22419)
struct LetterSentView: View {
    @Environment(\.dismiss) private var dismiss
    let stampImageName: String
    var onComplete: (() -> Void)?

    init(stampImageName: String = "StampOnLetter", onComplete: (() -> Void)? = nil) {
        self.stampImageName = stampImageName
        self.onComplete = onComplete
    }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                header

                Spacer()

                envelopeWithStamp
                    .padding(.bottom, 40)

                VStack(spacing: 12) {
                    Text("信件已寄出")
                        .font(AppFont.title(24))
                        .foregroundStyle(Color.textPrimary)
                        .tracking(-0.6)

                    Text("一枚邮票已随信寄出")
                        .font(AppFont.body(16))
                        .foregroundStyle(Color.textSecondary)
                }

                Spacer()

                Button {
                    if let onComplete {
                        onComplete()
                    } else {
                        dismiss()
                    }
                } label: {
                    Text("完成")
                        .font(AppFont.body(16))
                        .foregroundStyle(Color.mindPrimary)
                        .underline()
                }
                .padding(.bottom, 60)
            }
            .responsiveFill()
        }
    }

    private var background: some View {
        ZStack {
            Color.pageBackground
            RadialGradient(
                colors: [Color.warmGradientTop.opacity(0.4), .clear],
                center: .topLeading, startRadius: 0, endRadius: 500
            )
            RadialGradient(
                colors: [Color.warmGradientHot.opacity(0.1), .clear],
                center: .topTrailing, startRadius: 0, endRadius: 500
            )
        }
        .ignoresSafeArea()
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.textPrimary)
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var envelopeWithStamp: some View {
        ZStack {
            Image("EnvelopeImage")
                .resizable()
                .scaledToFit()
                .frame(width: 256, height: 145)
                .overlay(
                    Color.inkBrownAvatar.opacity(0.4)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.textPrimary.opacity(0.06), radius: 16, y: 12)

            // Floating stamp in top-right
            Image(stampImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 52, height: 68)
                .padding(6)
                .background(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.stampDashed.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [4, 3]))
                )
                .shadow(color: Color.textPrimary.opacity(0.1), radius: 8, y: 6)
                .rotationEffect(.degrees(12))
                .offset(x: 80, y: -60)
        }
    }
}
