import SwiftUI

/// 時計の表示スタイル
enum ClockFaceStyle: String, Codable, CaseIterable, Identifiable {
    case dotMatrix
    case analog
    case digital

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dotMatrix: return "ドット時計"
        case .analog:    return "アナログ"
        case .digital:   return "デジタル"
        }
    }
}

/// 時計フェイスのデザイン設定（App Group 経由で共有）
struct ClockFaceDesign: Codable, Equatable {
    /// 表示スタイル
    var style: ClockFaceStyle
    /// 針・ドット・文字の色（例 "#FFFFFF"）
    var tintHex: String
    /// 背景色（例 "#000000"）
    var backgroundHex: String
    /// デジタル表示などの秒表示フラグ
    var showSeconds: Bool
    /// dotMatrix 用のドット相対サイズ 0.3〜1.0
    var dotSize: Double

    static let `default` = ClockFaceDesign(
        style: .analog,
        tintHex: "#FFFFFF",
        backgroundHex: "#1C1C1E",
        showSeconds: false,
        dotSize: 0.7
    )
}

// MARK: - Color <-> Hex

extension Color {
    /// "#RRGGBB" / "RRGGBB" 形式の文字列から Color を生成する。
    /// 不正な値の場合は黒にフォールバックする。
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexSanitized.hasPrefix("#") {
            hexSanitized.removeFirst()
        }

        guard hexSanitized.count == 6,
              let rgb = UInt64(hexSanitized, radix: 16) else {
            // 不正値は黒にフォールバック
            self = Color(red: 0, green: 0, blue: 0)
            return
        }

        let red   = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue  = Double(rgb & 0x0000FF) / 255.0

        self = Color(red: red, green: green, blue: blue)
    }

    /// この Color を "#RRGGBB" 形式の文字列に変換する。
    /// 取得に失敗した場合は "#000000" を返す。
    var hexString: String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return "#000000"
        }

        let r = Int((red * 255).rounded())
        let g = Int((green * 255).rounded())
        let b = Int((blue * 255).rounded())
        return String(format: "#%02X%02X%02X", r, g, b)
        #else
        return "#000000"
        #endif
    }
}
