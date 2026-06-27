//
//  ClockPreset.swift
//  Clock-Widget
//
//  プリセット（名前付きデザイン）の共有モデルとストア。
//

import Foundation
import WidgetKit

/// 名前付きのデザインプリセット。App Group 経由で共有する。
struct ClockPreset: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var design: ClockFaceDesign
}

/// App Group の UserDefaults を介してプリセット配列を読み書きするストア。
enum ClockPresetStore {
    static let appGroupID = "group.com.Clock-Widget"
    static let key = "clockPresets"

    /// App Group suite が利用できればそれを、無ければ標準 UserDefaults を返す。
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    /// 保存済みのプリセット一覧を読み込む。無い／デコード失敗時は空配列。
    static func loadAll() -> [ClockPreset] {
        guard let data = defaults.data(forKey: key),
              let presets = try? JSONDecoder().decode([ClockPreset].self, from: data) else {
            return []
        }
        return presets
    }

    /// プリセット配列を JSON エンコードして保存し、全ウィジェットをリロードする。
    static func saveAll(_ presets: [ClockPreset]) {
        if let data = try? JSONEncoder().encode(presets) {
            defaults.set(data, forKey: key)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    /// 新規プリセットを採番して追加保存する。
    static func add(name: String, design: ClockFaceDesign) {
        var presets = loadAll()
        presets.append(ClockPreset(id: UUID(), name: name, design: design))
        saveAll(presets)
    }

    /// 指定 id のプリセットを削除する。
    static func delete(id: UUID) {
        var presets = loadAll()
        presets.removeAll { $0.id == id }
        saveAll(presets)
    }

    /// 指定 id のプリセットを取得する。無ければ nil。
    static func preset(id: UUID) -> ClockPreset? {
        loadAll().first { $0.id == id }
    }
}
