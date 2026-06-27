import SwiftUI

/// アプリ専用のドット時計エディタ。SwiftUI の `Form` 内に置くことを想定。
///
/// ここではドットの意匠（形状・サイズ・発光）のみを扱う。
/// 秒・24時間・色は別担当が扱うため、このセクションには含めない。
struct DotMatrixEditorSection: View {
    @Binding var design: ClockFaceDesign

    var body: some View {
        Section("ドット時計") {
            Picker("ドット形状", selection: $design.dotShape) {
                ForEach(DotShape.allCases) { shape in
                    Text(shape.displayName).tag(shape)
                }
            }

            VStack(alignment: .leading) {
                Text("ドットサイズ: \(Int(design.dotSize * 100))%")
                Slider(value: $design.dotSize, in: 0.3...1.0)
            }

            Toggle("発光", isOn: $design.dotGlow)
        }
    }
}
