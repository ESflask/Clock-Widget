import Foundation
import WidgetKit

/// `ClockFaceDesign` を読み書きするストア。
///
/// App Group が使える環境（有料アカウントの実機 / Simulator）ではアプリ↔拡張で共有される。
/// 無料(Personal Team)の実機では App Group entitlement を付けられないため、
/// その場合は標準 UserDefaults にフォールバックする（プロセス間共有はされない）。
enum ClockFaceStore {
    static let appGroupID = "group.com.Clock-Widget"
    static let key = "clockFaceDesign"

    /// App Group suite が利用できればそれを、無ければ標準 UserDefaults を返す。
    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    /// 保存済みデザインを読み込む。値が無い／デコード失敗時は `.default`。
    static func load() -> ClockFaceDesign {
        guard let data = defaults.data(forKey: key),
              let design = try? JSONDecoder().decode(ClockFaceDesign.self, from: data) else {
            return .default
        }
        return design
    }

    /// デザインを保存し、全ウィジェットのタイムラインをリロードする。
    static func save(_ design: ClockFaceDesign) {
        if let data = try? JSONEncoder().encode(design) {
            defaults.set(data, forKey: key)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
