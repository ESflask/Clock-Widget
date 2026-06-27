import SwiftUI

/// アナログ盤の意匠（マーカー・密度・針形状・中心キャップ）を編集するエディタ。
/// SwiftUI の `Form` 内に置くことを想定。
/// 秒表示・色はここでは扱わない（別担当）。
struct AnalogEditorSection: View {
    @Binding var design: ClockFaceDesign

    var body: some View {
        Section("アナログ盤") {
            Picker("マーカー", selection: $design.markerStyle) {
                ForEach(MarkerStyle.allCases) { style in
                    Text(style.displayName).tag(style)
                }
            }

            Picker("目盛の密度", selection: $design.markerDensity) {
                ForEach(MarkerDensity.allCases) { density in
                    Text(density.displayName).tag(density)
                }
            }

            Picker("針の形", selection: $design.handShape) {
                ForEach(HandShape.allCases) { shape in
                    Text(shape.displayName).tag(shape)
                }
            }

            Toggle("中心キャップを表示", isOn: $design.showCenterCap)
        }
    }
}
