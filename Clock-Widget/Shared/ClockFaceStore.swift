import Foundation
import WidgetKit

/// App Group の UserDefaults を介して `ClockFaceDesign` を読み書きするストア。
enum ClockFaceStore {
    static let appGroupID = "group.com.Clock-Widget"
    static let key = "clockFaceDesign"

    /// App Group の UserDefaults から保存済みデザインを読み込む。
    /// 値が無い、またはデコードに失敗した場合は `.default` を返す。
    static func load() -> ClockFaceDesign {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: key),
              let design = try? JSONDecoder().decode(ClockFaceDesign.self, from: data) else {
            return .default
        }
        return design
    }

    /// デザインを JSON エンコードして App Group の UserDefaults に保存し、
    /// 全ウィジェットのタイムラインをリロードする。
    static func save(_ design: ClockFaceDesign) {
        if let defaults = UserDefaults(suiteName: appGroupID),
           let data = try? JSONEncoder().encode(design) {
            defaults.set(data, forKey: key)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
