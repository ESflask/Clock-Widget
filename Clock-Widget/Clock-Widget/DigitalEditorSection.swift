import SwiftUI

/// アプリ専用のデジタル書式エディタ（D）。SwiftUI の `Form` 内に置くことを想定。
struct DigitalEditorSection: View {
    @Binding var design: ClockFaceDesign

    var body: some View {
        Section("デジタル書式") {
            Picker("フォント", selection: $design.digitalFont) {
                ForEach(DigitalFont.allCases) { font in
                    Text(font.displayName).tag(font)
                }
            }

            Picker("太さ", selection: $design.fontWeight) {
                ForEach(FontWeightOption.allCases) { weight in
                    Text(weight.displayName).tag(weight)
                }
            }

            Toggle("24時間表示", isOn: $design.use24Hour)

            Toggle("AM/PM を表示", isOn: $design.showAMPM)
                .disabled(design.use24Hour)

            Toggle("先頭ゼロ", isOn: $design.leadingZero)
        }
    }
}
