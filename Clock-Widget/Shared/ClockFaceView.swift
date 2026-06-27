import SwiftUI

/// 時計フェイスの合成ビュー。
/// 背景（A）→ スタイル別の盤面（B/C/D）→ 付加情報（E）を ZStack で重ねる。
struct ClockFaceView: View {
    let design: ClockFaceDesign
    let date: Date

    var body: some View {
        ZStack {
            ClockBackgroundView(design: design)
            faceContent
            ComplicationOverlay(design: design, date: date)
        }
        .clipped()
    }

    @ViewBuilder
    private var faceContent: some View {
        switch design.style {
        case .analog:
            AnalogFaceView(design: design, date: date)
        case .dotMatrix:
            DotMatrixFaceView(design: design, date: date)
        case .digital:
            DigitalFaceView(design: design, date: date)
        }
    }
}
