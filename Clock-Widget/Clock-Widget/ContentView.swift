import SwiftUI

struct ContentView: View {
    @State private var design: ClockFaceDesign = ClockFaceStore.load()
    @State private var showFullScreen = false

    var body: some View {
        NavigationStack {
            Form {
                // ライブプレビュー
                Section {
                    ClockFaceView(design: design, date: .now)
                        .frame(width: 168, height: 168)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 8)
                        .listRowBackground(Color.clear)
                }

                // 共通設定（スタイル・秒表示）
                Section("スタイル") {
                    Picker("スタイル", selection: $design.style) {
                        ForEach(ClockFaceStyle.allCases) { style in
                            Text(style.displayName).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)

                    Toggle("秒を表示", isOn: $design.showSeconds)
                }

                // 盤面サイズ（全スタイル共通）
                SizeEditorSection(design: $design)

                // 色・背景（A）
                ColorEditorSection(design: $design)

                // スタイル別の意匠（B/C/D）
                if design.style == .analog {
                    AnalogEditorSection(design: $design)
                }
                if design.style == .dotMatrix {
                    DotMatrixEditorSection(design: $design)
                }
                if design.style == .digital {
                    DigitalEditorSection(design: $design)
                }

                // 付加情報（E）
                InfoEditorSection(design: $design)

                // プリセット（F）
                PresetEditorSection(design: $design)
            }
            .navigationTitle("時計ウィジェット編集")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFullScreen = true
                    } label: {
                        Label("全画面", systemImage: "arrow.up.left.and.arrow.down.right")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showFullScreen) {
            FullScreenClockView(design: design)
        }
        .onChange(of: design) { _, newValue in
            ClockFaceStore.save(newValue)
        }
    }
}

#Preview {
    ContentView()
}
