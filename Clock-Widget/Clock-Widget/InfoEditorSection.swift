import SwiftUI

/// アプリ専用の付加情報エディタ（E）。SwiftUI の `Form` 内に置くことを想定。
struct InfoEditorSection: View {
    @Binding var design: ClockFaceDesign

    var body: some View {
        Section("付加情報") {
            Toggle("日付を表示", isOn: $design.showDate)
            Toggle("曜日を表示", isOn: $design.showWeekday)
            TextField("ひとこと", text: $design.customText)
        }
    }
}
