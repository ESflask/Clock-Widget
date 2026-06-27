//
//  PresetEditorSection.swift
//  Clock-Widget
//
//  編集中デザインのプリセット保存／適用／削除を行う Form 内セクション。
//

import SwiftUI

struct PresetEditorSection: View {
    /// 編集中のデザイン。プリセット適用時にここへ反映する。
    @Binding var design: ClockFaceDesign

    @State private var presets: [ClockPreset] = ClockPresetStore.loadAll()
    @State private var newName: String = ""

    var body: some View {
        Section("プリセット") {
            // --- 現在のデザインを保存 ---
            HStack {
                TextField("プリセット名", text: $newName)
                    .textFieldStyle(.roundedBorder)

                Button("保存") {
                    saveCurrent()
                }
                .buttonStyle(.borderedProminent)
                .disabled(trimmedName.isEmpty)
            }

            // --- 保存済み一覧 ---
            if presets.isEmpty {
                Text("保存済みのプリセットはありません")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            } else {
                ForEach(presets) { preset in
                    Button {
                        design = preset.design
                    } label: {
                        HStack(spacing: 12) {
                            ClockFaceView(design: preset.design, date: .now)
                                .frame(width: 36, height: 36)
                                .background(Color(hex: preset.design.backgroundHex))
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Text(preset.name)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "arrow.down.circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            delete(preset)
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .onAppear {
            reload()
        }
    }

    private var trimmedName: String {
        newName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func saveCurrent() {
        let name = trimmedName
        guard !name.isEmpty else { return }
        ClockPresetStore.add(name: name, design: design)
        newName = ""
        reload()
    }

    private func delete(_ preset: ClockPreset) {
        ClockPresetStore.delete(id: preset.id)
        reload()
    }

    private func reload() {
        presets = ClockPresetStore.loadAll()
    }
}
