import SwiftUI

/// 滑动确认按钮 (swipe-to-confirm)
///
/// 设计:
/// - 椭圆胶囊毛玻璃轨道 + 中央文字
/// - 左侧白色圆形 knob, 用户向右拖到末尾触发 onComplete
/// - 拖动距离不足时自动回弹
/// - 触发时 success haptic
///
/// 用于 Onboarding 最后一步的"开始你的记录旅程", 替代普通 Button
/// (后者按下会变透明且没有滑动语义).
struct SlideToConfirmButton: View {
    let text: String
    let onComplete: () -> Void

    var trackWidth: CGFloat = 280
    var trackHeight: CGFloat = 58
    var knobSize: CGFloat = 44
    var trackPadding: CGFloat = 7

    /// 触发完成的拖拽阈值占比 (0 - 1)
    var thresholdRatio: CGFloat = 0.6

    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted = false

    private var maxOffset: CGFloat {
        trackWidth - knobSize - trackPadding * 2
    }

    var body: some View {
        ZStack(alignment: .leading) {
            track
            knob
        }
        .frame(width: trackWidth, height: trackHeight)
        // 防止整体被父级 Button 样式吞掉
        .allowsHitTesting(!isCompleted)
    }

    private var track: some View {
        ZStack {
            Capsule()
                .fill(.ultraThinMaterial)

            Capsule()
                .stroke(Color.white.opacity(0.4), lineWidth: 1)

            Text(text)
                .font(AppFont.body(15))
                .foregroundStyle(Color.textPrimary.opacity(textOpacity))
                .tracking(5.2)
                // 给 knob 留位置, 文字仅在 knob 右侧
                .padding(.leading, knobSize + trackPadding * 2)
                .padding(.trailing, trackPadding * 2)
                .frame(maxWidth: .infinity, alignment: .center)
                .allowsHitTesting(false)
        }
    }

    private var knob: some View {
        Circle()
            .fill(Color.white.opacity(0.95))
            .frame(width: knobSize, height: knobSize)
            .overlay(
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
            )
            .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            .offset(x: trackPadding + dragOffset)
            .gesture(dragGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard !isCompleted else { return }
                let clamped = min(max(0, value.translation.width), maxOffset)
                dragOffset = clamped
            }
            .onEnded { _ in
                guard !isCompleted else { return }
                if dragOffset >= maxOffset * thresholdRatio {
                    completeSlide()
                } else {
                    bounceBack()
                }
            }
    }

    private func completeSlide() {
        isCompleted = true
        Haptic.success()
        withAnimation(.easeOut(duration: 0.18)) {
            dragOffset = maxOffset
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            onComplete()
        }
    }

    private func bounceBack() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            dragOffset = 0
        }
    }

    /// 文字随拖拽逐渐淡出 (拖到底时为 0.3, 提供反馈)
    private var textOpacity: Double {
        guard maxOffset > 0 else { return 1 }
        let progress = Double(dragOffset / maxOffset)
        return 1 - progress * 0.7
    }
}
