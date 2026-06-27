import SwiftUI

/// アプリ専用の色・質感エディタ。SwiftUI の `Form` 内に置くことを想定。
struct ColorEditorSection: View {
    @Binding var design: ClockFaceDesign

    var body: some View {
        backgroundSection
        foregroundSection
        elementColorSection
        accentSection
    }

    // MARK: - 背景

    private var backgroundSection: some View {
        Section("背景") {
            Picker("種類", selection: $design.backgroundKind) {
                ForEach(BackgroundKind.allCases) { kind in
                    Text(kind.displayName).tag(kind)
                }
            }

            ColorPicker("背景色", selection: hexBinding(\.backgroundHex))

            if design.backgroundKind != .solid {
                ColorPicker("背景色 2", selection: hexBinding(\.backgroundHex2))
            }

            VStack(alignment: .leading) {
                Text("不透明度: \(Int(design.backgroundOpacity * 100))%")
                Slider(value: $design.backgroundOpacity, in: 0...1)
            }
        }
    }

    // MARK: - 前景色

    private var foregroundSection: some View {
        Section("前景色") {
            ColorPicker("既定色", selection: hexBinding(\.tintHex))
        }
    }

    // MARK: - 要素別カラー（任意）

    private var elementColorSection: some View {
        Section("要素別カラー（任意）") {
            elementColorRow(title: "時針", keyPath: \.hourHandHex)
            elementColorRow(title: "分針", keyPath: \.minuteHandHex)
            elementColorRow(title: "秒針", keyPath: \.secondHandHex)
            elementColorRow(title: "マーカー", keyPath: \.markerHex)
        }
    }

    @ViewBuilder
    private func elementColorRow(title: String,
                                 keyPath: WritableKeyPath<ClockFaceDesign, String>) -> some View {
        let followsTint = design[keyPath: keyPath].isEmpty

        VStack(alignment: .leading, spacing: 4) {
            Toggle("\(title): tintに従う", isOn: Binding(
                get: { design[keyPath: keyPath].isEmpty },
                set: { isOn in
                    if isOn {
                        design[keyPath: keyPath] = ""
                    } else {
                        // オフにしたら現在の tint 色を初期値として入れる
                        design[keyPath: keyPath] = Color(hex: design.tintHex).hexString
                    }
                }))

            if !followsTint {
                ColorPicker("\(title)の色", selection: hexBinding(keyPath))
            }
        }
    }

    // MARK: - 強調

    private var accentSection: some View {
        Section("強調") {
            Toggle("強調を使う", isOn: $design.useAccent)
            ColorPicker("強調色", selection: hexBinding(\.accentHex))
                .disabled(!design.useAccent)
        }
    }

    // MARK: - Hex <-> Color ブリッジ

    private func hexBinding(_ keyPath: WritableKeyPath<ClockFaceDesign, String>) -> Binding<Color> {
        Binding(
            get: { Color(hex: design[keyPath: keyPath]) },
            set: { design[keyPath: keyPath] = $0.hexString }
        )
    }
}
