import SwiftUI

// MARK: - Style & option enums

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

/// 背景の種類（A: 色・質感）
enum BackgroundKind: String, Codable, CaseIterable, Identifiable {
    case solid
    case linearGradient
    case radialGradient

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .solid:          return "単色"
        case .linearGradient: return "線形グラデ"
        case .radialGradient: return "放射グラデ"
        }
    }
}

/// アナログのマーカー（時刻目盛）の種別（B: 盤面意匠）
enum MarkerStyle: String, Codable, CaseIterable, Identifiable {
    case dots
    case lines
    case arabic
    case roman
    case none

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .dots:   return "ドット"
        case .lines:  return "線"
        case .arabic: return "数字"
        case .roman:  return "ローマ"
        case .none:   return "なし"
        }
    }
}

/// アナログのマーカー密度（B）
enum MarkerDensity: String, Codable, CaseIterable, Identifiable {
    case four    // 4分割（3/6/9/12）
    case twelve  // 12分割
    case sixty   // 60分割（分目盛）

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .four:   return "4分割"
        case .twelve: return "12分割"
        case .sixty:  return "60分割"
        }
    }
}

/// アナログの針形状（B）
enum HandShape: String, Codable, CaseIterable, Identifiable {
    case line
    case tapered
    case rounded

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .line:    return "直線"
        case .tapered: return "テーパー"
        case .rounded: return "丸み"
        }
    }
}

/// ドット時計のドット形状（C）
enum DotShape: String, Codable, CaseIterable, Identifiable {
    case circle
    case roundedSquare
    case square

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .circle:        return "円"
        case .roundedSquare: return "角丸"
        case .square:        return "四角"
        }
    }
}

/// デジタルのフォント種別（D）
enum DigitalFont: String, Codable, CaseIterable, Identifiable {
    case system
    case rounded
    case monospaced
    case serif

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:     return "システム"
        case .rounded:    return "丸ゴ"
        case .monospaced: return "等幅"
        case .serif:      return "セリフ"
        }
    }

    /// SwiftUI の Font.Design へのマッピング
    var fontDesign: Font.Design {
        switch self {
        case .system:     return .default
        case .rounded:    return .rounded
        case .monospaced: return .monospaced
        case .serif:      return .serif
        }
    }
}

/// フォントの太さ（D）
enum FontWeightOption: String, Codable, CaseIterable, Identifiable {
    case regular
    case medium
    case bold

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .regular: return "細"
        case .medium:  return "中"
        case .bold:    return "太"
        }
    }

    var weight: Font.Weight {
        switch self {
        case .regular: return .regular
        case .medium:  return .medium
        case .bold:    return .bold
        }
    }
}

// MARK: - Design model

/// 時計フェイスのデザイン設定（App Group 経由で共有）
///
/// すべてのフィールドはデコード時に欠損していても `default` 値で補完されるため、
/// 古い保存データからの読み込みでもクラッシュしない。
struct ClockFaceDesign: Codable, Equatable {
    // --- 共通 ---
    /// 表示スタイル
    var style: ClockFaceStyle
    /// 既定の前景色（針・ドット・文字の既定色）"#RRGGBB"
    var tintHex: String
    /// 秒表示フラグ
    var showSeconds: Bool

    // --- A: 色・背景 ---
    /// 背景の種類
    var backgroundKind: BackgroundKind
    /// 背景色（単色／グラデ開始色）
    var backgroundHex: String
    /// グラデーション終了色
    var backgroundHex2: String
    /// 背景の不透明度 0.0〜1.0
    var backgroundOpacity: Double
    /// 時針の色（空文字なら tint を継承）
    var hourHandHex: String
    /// 分針の色（空文字なら tint を継承）
    var minuteHandHex: String
    /// 秒針の色（空文字なら tint を継承）
    var secondHandHex: String
    /// マーカー／ドット消灯以外の色（空文字なら tint を継承）
    var markerHex: String
    /// 現在時マーカーを強調するか
    var useAccent: Bool
    /// 強調色
    var accentHex: String

    // --- B: アナログ ---
    var markerStyle: MarkerStyle
    var markerDensity: MarkerDensity
    var handShape: HandShape
    var showCenterCap: Bool

    // --- C: ドット ---
    /// ドット相対サイズ 0.3〜1.0
    var dotSize: Double
    var dotShape: DotShape
    /// 発光（グロー）風表現
    var dotGlow: Bool

    // --- D: デジタル ---
    var digitalFont: DigitalFont
    var fontWeight: FontWeightOption
    /// 24時間表示
    var use24Hour: Bool
    /// AM/PM 併記（12時間時）
    var showAMPM: Bool
    /// 先頭ゼロ（09:05 など）
    var leadingZero: Bool

    // --- E: 付加情報 ---
    var showDate: Bool
    var showWeekday: Bool
    /// 盤面に重ねるカスタム文字列（空なら非表示）
    var customText: String

    // --- 盤面サイズ ---
    /// 時計盤の相対サイズ 0.4〜1.0（表示領域に対する縮尺）
    var faceScale: Double

    static let `default` = ClockFaceDesign(
        style: .analog,
        tintHex: "#FFFFFF",
        showSeconds: false,
        backgroundKind: .solid,
        backgroundHex: "#1C1C1E",
        backgroundHex2: "#3A3A3C",
        backgroundOpacity: 1.0,
        hourHandHex: "",
        minuteHandHex: "",
        secondHandHex: "",
        markerHex: "",
        useAccent: false,
        accentHex: "#FF375F",
        markerStyle: .lines,
        markerDensity: .twelve,
        handShape: .rounded,
        showCenterCap: true,
        dotSize: 0.7,
        dotShape: .circle,
        dotGlow: false,
        digitalFont: .rounded,
        fontWeight: .medium,
        use24Hour: true,
        showAMPM: false,
        leadingZero: true,
        showDate: false,
        showWeekday: false,
        customText: "",
        faceScale: 1.0
    )

    // 欠損キーを default で補完する寛容なデコーダ
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = ClockFaceDesign.default
        style             = try c.decodeIfPresent(ClockFaceStyle.self, forKey: .style) ?? d.style
        tintHex           = try c.decodeIfPresent(String.self, forKey: .tintHex) ?? d.tintHex
        showSeconds       = try c.decodeIfPresent(Bool.self, forKey: .showSeconds) ?? d.showSeconds
        backgroundKind    = try c.decodeIfPresent(BackgroundKind.self, forKey: .backgroundKind) ?? d.backgroundKind
        backgroundHex     = try c.decodeIfPresent(String.self, forKey: .backgroundHex) ?? d.backgroundHex
        backgroundHex2    = try c.decodeIfPresent(String.self, forKey: .backgroundHex2) ?? d.backgroundHex2
        backgroundOpacity = try c.decodeIfPresent(Double.self, forKey: .backgroundOpacity) ?? d.backgroundOpacity
        hourHandHex       = try c.decodeIfPresent(String.self, forKey: .hourHandHex) ?? d.hourHandHex
        minuteHandHex     = try c.decodeIfPresent(String.self, forKey: .minuteHandHex) ?? d.minuteHandHex
        secondHandHex     = try c.decodeIfPresent(String.self, forKey: .secondHandHex) ?? d.secondHandHex
        markerHex         = try c.decodeIfPresent(String.self, forKey: .markerHex) ?? d.markerHex
        useAccent         = try c.decodeIfPresent(Bool.self, forKey: .useAccent) ?? d.useAccent
        accentHex         = try c.decodeIfPresent(String.self, forKey: .accentHex) ?? d.accentHex
        markerStyle       = try c.decodeIfPresent(MarkerStyle.self, forKey: .markerStyle) ?? d.markerStyle
        markerDensity     = try c.decodeIfPresent(MarkerDensity.self, forKey: .markerDensity) ?? d.markerDensity
        handShape         = try c.decodeIfPresent(HandShape.self, forKey: .handShape) ?? d.handShape
        showCenterCap     = try c.decodeIfPresent(Bool.self, forKey: .showCenterCap) ?? d.showCenterCap
        dotSize           = try c.decodeIfPresent(Double.self, forKey: .dotSize) ?? d.dotSize
        dotShape          = try c.decodeIfPresent(DotShape.self, forKey: .dotShape) ?? d.dotShape
        dotGlow           = try c.decodeIfPresent(Bool.self, forKey: .dotGlow) ?? d.dotGlow
        digitalFont       = try c.decodeIfPresent(DigitalFont.self, forKey: .digitalFont) ?? d.digitalFont
        fontWeight        = try c.decodeIfPresent(FontWeightOption.self, forKey: .fontWeight) ?? d.fontWeight
        use24Hour         = try c.decodeIfPresent(Bool.self, forKey: .use24Hour) ?? d.use24Hour
        showAMPM          = try c.decodeIfPresent(Bool.self, forKey: .showAMPM) ?? d.showAMPM
        leadingZero       = try c.decodeIfPresent(Bool.self, forKey: .leadingZero) ?? d.leadingZero
        showDate          = try c.decodeIfPresent(Bool.self, forKey: .showDate) ?? d.showDate
        showWeekday       = try c.decodeIfPresent(Bool.self, forKey: .showWeekday) ?? d.showWeekday
        customText        = try c.decodeIfPresent(String.self, forKey: .customText) ?? d.customText
        faceScale         = try c.decodeIfPresent(Double.self, forKey: .faceScale) ?? d.faceScale
    }

    // メンバーワイズ初期化子（init(from:) を定義したため明示的に用意）
    init(
        style: ClockFaceStyle,
        tintHex: String,
        showSeconds: Bool,
        backgroundKind: BackgroundKind,
        backgroundHex: String,
        backgroundHex2: String,
        backgroundOpacity: Double,
        hourHandHex: String,
        minuteHandHex: String,
        secondHandHex: String,
        markerHex: String,
        useAccent: Bool,
        accentHex: String,
        markerStyle: MarkerStyle,
        markerDensity: MarkerDensity,
        handShape: HandShape,
        showCenterCap: Bool,
        dotSize: Double,
        dotShape: DotShape,
        dotGlow: Bool,
        digitalFont: DigitalFont,
        fontWeight: FontWeightOption,
        use24Hour: Bool,
        showAMPM: Bool,
        leadingZero: Bool,
        showDate: Bool,
        showWeekday: Bool,
        customText: String,
        faceScale: Double
    ) {
        self.style = style
        self.tintHex = tintHex
        self.showSeconds = showSeconds
        self.backgroundKind = backgroundKind
        self.backgroundHex = backgroundHex
        self.backgroundHex2 = backgroundHex2
        self.backgroundOpacity = backgroundOpacity
        self.hourHandHex = hourHandHex
        self.minuteHandHex = minuteHandHex
        self.secondHandHex = secondHandHex
        self.markerHex = markerHex
        self.useAccent = useAccent
        self.accentHex = accentHex
        self.markerStyle = markerStyle
        self.markerDensity = markerDensity
        self.handShape = handShape
        self.showCenterCap = showCenterCap
        self.dotSize = dotSize
        self.dotShape = dotShape
        self.dotGlow = dotGlow
        self.digitalFont = digitalFont
        self.fontWeight = fontWeight
        self.use24Hour = use24Hour
        self.showAMPM = showAMPM
        self.leadingZero = leadingZero
        self.showDate = showDate
        self.showWeekday = showWeekday
        self.customText = customText
        self.faceScale = faceScale
    }
}

// MARK: - 色の解決ヘルパー

extension ClockFaceDesign {
    /// 空文字なら tint を継承して Color を返す
    func resolvedColor(_ hex: String) -> Color {
        hex.isEmpty ? Color(hex: tintHex) : Color(hex: hex)
    }

    var tintColor: Color { Color(hex: tintHex) }
    var hourHandColor: Color { resolvedColor(hourHandHex) }
    var minuteHandColor: Color { resolvedColor(minuteHandHex) }
    var secondHandColor: Color { resolvedColor(secondHandHex) }
    var markerColor: Color { resolvedColor(markerHex) }
    var accentColor: Color { Color(hex: accentHex) }
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
