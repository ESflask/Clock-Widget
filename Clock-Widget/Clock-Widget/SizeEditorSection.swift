import SwiftUI

/// 盤面サイズ（faceScale）の編集セクション。全スタイル共通。
struct SizeEditorSection: View {
    @Binding var design: ClockFaceDesign

    var body: some View {
        Section("盤面サイズ") {
            VStack(alignment: .leading) {
                Text("盤面サイズ: \(Int((design.faceScale * 100).rounded()))%")
                Slider(value: $design.faceScale, in: 0.4...1.0)
            }
        }
    }
}
