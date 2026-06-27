//
//  ContentView.swift
//  Clock-Widget
//

import SwiftUI

struct ContentView: View {
    @State private var design: ClockFaceDesign = ClockFaceStore.load()

    private var tintColor: Binding<Color> {
        Binding(
            get: { Color(hex: design.tintHex) },
            set: { design.tintHex = $0.hexString }
        )
    }

    private var backgroundColor: Binding<Color> {
        Binding(
            get: { Color(hex: design.backgroundHex) },
            set: { design.backgroundHex = $0.hexString }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ClockFaceView(design: design, date: .now)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 220)
                        .background(Color(hex: design.backgroundHex))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }

                Section("スタイル") {
                    Picker("スタイル", selection: $design.style) {
                        ForEach(ClockFaceStyle.allCases) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("カラー") {
                    ColorPicker("前景色", selection: tintColor, supportsOpacity: false)
                    ColorPicker("背景色", selection: backgroundColor, supportsOpacity: false)
                }

                Section("表示") {
                    Toggle("秒を表示", isOn: $design.showSeconds)

                    if design.style == .dotMatrix {
                        VStack(alignment: .leading) {
                            Text("ドットサイズ")
                            Slider(value: $design.dotSize, in: 0.3...1.0)
                        }
                    }
                }
            }
            .navigationTitle("時計ウィジェット編集")
            .onChange(of: design) { _, newValue in
                ClockFaceStore.save(newValue)
            }
        }
    }
}

#Preview {
    ContentView()
}
