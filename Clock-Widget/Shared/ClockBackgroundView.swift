import SwiftUI

/// 時計の背景のみを描画する View。
/// 針・ドット・文字などの前景は描かない。
struct ClockBackgroundView: View {
    let design: ClockFaceDesign

    var body: some View {
        background
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(design.backgroundOpacity)
    }

    @ViewBuilder
    private var background: some View {
        switch design.backgroundKind {
        case .solid:
            Color(hex: design.backgroundHex)

        case .linearGradient:
            LinearGradient(
                colors: [
                    Color(hex: design.backgroundHex),
                    Color(hex: design.backgroundHex2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .radialGradient:
            GeometryReader { proxy in
                let radius = max(proxy.size.width, proxy.size.height) / 2
                RadialGradient(
                    colors: [
                        Color(hex: design.backgroundHex),
                        Color(hex: design.backgroundHex2)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: radius
                )
            }
        }
    }
}
