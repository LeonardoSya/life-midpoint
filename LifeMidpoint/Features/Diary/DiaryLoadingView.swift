import SwiftUI

struct DiaryLoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Color.pageBackground.ignoresSafeArea()

            VStack(spacing: 24) {
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.brandMutedGold.opacity(0.4), lineWidth: 1.5)
                            .frame(width: CGFloat(40 + i * 20), height: CGFloat(40 + i * 20))
                            .rotationEffect(.degrees(rotation + Double(i * 120)))
                    }
                    Circle()
                        .fill(Color.brandMutedGold)
                        .frame(width: 12, height: 12)
                }
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        rotation = 360
                    }
                }

                Text("正在整理你的心声...")
                    .font(AppFont.body(14))
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
}
