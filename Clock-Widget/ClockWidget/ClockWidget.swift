import WidgetKit
import SwiftUI
import AppIntents

// MARK: - 設定用 AppEnum（ウィジェット「編集」画面のピッカーに表示）
// App Group を使わず、ウィジェット自身の構成（iOS が個別保存）でデザインを決める。
// 無料(Personal Team)アカウントの実機でもカスタマイズ可能。

/// 色はカラーホイールを置けないため定義済みパレットから選ぶ。
enum ColorChoice: String, AppEnum {
    case white, black, gray, red, orange, yellow, green, mint, blue, indigo, purple, pink

    static var typeDisplayRepresentation: TypeDisplayRepresentation { "色" }
    static var caseDisplayRepresentations: [ColorChoice: DisplayRepresentation] {
        [
            .white: "ホワイト", .black: "ブラック", .gray: "グレー", .red: "レッド",
            .orange: "オレンジ", .yellow: "イエロー", .green: "グリーン", .mint: "ミント",
            .blue: "ブルー", .indigo: "インディゴ", .purple: "パープル", .pink: "ピンク",
        ]
    }

    var hex: String {
        switch self {
        case .white:  return "#FFFFFF"
        case .black:  return "#000000"
        case .gray:   return "#1C1C1E"
        case .red:    return "#FF3B30"
        case .orange: return "#FF9500"
        case .yellow: return "#FFD60A"
        case .green:  return "#34C759"
        case .mint:   return "#00C7BE"
        case .blue:   return "#0A84FF"
        case .indigo: return "#5E5CE6"
        case .purple: return "#BF5AF2"
        case .pink:   return "#FF375F"
        }
    }
}

enum StyleChoice: String, AppEnum {
    case analog, dotMatrix, digital
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "スタイル" }
    static var caseDisplayRepresentations: [StyleChoice: DisplayRepresentation] {
        [.analog: "アナログ", .dotMatrix: "ドット時計", .digital: "デジタル"]
    }
    var model: ClockFaceStyle {
        switch self {
        case .analog:    return .analog
        case .dotMatrix: return .dotMatrix
        case .digital:   return .digital
        }
    }
}

enum BackgroundKindChoice: String, AppEnum {
    case solid, linearGradient, radialGradient
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "背景の種類" }
    static var caseDisplayRepresentations: [BackgroundKindChoice: DisplayRepresentation] {
        [.solid: "単色", .linearGradient: "線形グラデ", .radialGradient: "放射グラデ"]
    }
    var model: BackgroundKind {
        switch self {
        case .solid:          return .solid
        case .linearGradient: return .linearGradient
        case .radialGradient: return .radialGradient
        }
    }
}

enum MarkerStyleChoice: String, AppEnum {
    case dots, lines, arabic, roman, none
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "マーカー" }
    static var caseDisplayRepresentations: [MarkerStyleChoice: DisplayRepresentation] {
        [.dots: "ドット", .lines: "線", .arabic: "数字", .roman: "ローマ", .none: "なし"]
    }
    var model: MarkerStyle {
        switch self {
        case .dots:   return .dots
        case .lines:  return .lines
        case .arabic: return .arabic
        case .roman:  return .roman
        case .none:   return .none
        }
    }
}

enum HandShapeChoice: String, AppEnum {
    case line, tapered, rounded
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "針の形" }
    static var caseDisplayRepresentations: [HandShapeChoice: DisplayRepresentation] {
        [.line: "直線", .tapered: "テーパー", .rounded: "丸み"]
    }
    var model: HandShape {
        switch self {
        case .line:    return .line
        case .tapered: return .tapered
        case .rounded: return .rounded
        }
    }
}

enum DotShapeChoice: String, AppEnum {
    case circle, roundedSquare, square
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "ドット形状" }
    static var caseDisplayRepresentations: [DotShapeChoice: DisplayRepresentation] {
        [.circle: "円", .roundedSquare: "角丸", .square: "四角"]
    }
    var model: DotShape {
        switch self {
        case .circle:        return .circle
        case .roundedSquare: return .roundedSquare
        case .square:        return .square
        }
    }
}

enum DigitalFontChoice: String, AppEnum {
    case system, rounded, monospaced, serif
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "フォント" }
    static var caseDisplayRepresentations: [DigitalFontChoice: DisplayRepresentation] {
        [.system: "システム", .rounded: "丸ゴ", .monospaced: "等幅", .serif: "セリフ"]
    }
    var model: DigitalFont {
        switch self {
        case .system:     return .system
        case .rounded:    return .rounded
        case .monospaced: return .monospaced
        case .serif:      return .serif
        }
    }
}

// MARK: - ウィジェット構成 Intent（「ウィジェットを編集」画面）

struct ConfigureClockIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "時計をカスタマイズ" }
    static var description: IntentDescription { IntentDescription("ウィジェットの時計デザインを設定します。") }

    @Parameter(title: "スタイル", default: .analog) var style: StyleChoice
    @Parameter(title: "前景色", default: .white) var tint: ColorChoice
    @Parameter(title: "背景の種類", default: .solid) var backgroundKind: BackgroundKindChoice
    @Parameter(title: "背景色", default: .gray) var background: ColorChoice
    @Parameter(title: "背景色2（グラデ時）", default: .black) var background2: ColorChoice
    @Parameter(title: "秒を表示", default: false) var showSeconds: Bool
    @Parameter(title: "マーカー", default: .lines) var markerStyle: MarkerStyleChoice
    @Parameter(title: "針の形", default: .rounded) var handShape: HandShapeChoice
    @Parameter(title: "ドット形状", default: .circle) var dotShape: DotShapeChoice
    @Parameter(title: "フォント", default: .rounded) var digitalFont: DigitalFontChoice
    @Parameter(title: "24時間表示", default: true) var use24Hour: Bool
    @Parameter(title: "日付を表示", default: false) var showDate: Bool
    @Parameter(title: "曜日を表示", default: false) var showWeekday: Bool
    @Parameter(title: "ひとこと") var customText: String?

    /// Intent パラメータから ClockFaceDesign を組み立てる。未指定項目は default を継承。
    func makeDesign() -> ClockFaceDesign {
        var d = ClockFaceDesign.default
        d.style = style.model
        d.tintHex = tint.hex
        d.backgroundKind = backgroundKind.model
        d.backgroundHex = background.hex
        d.backgroundHex2 = background2.hex
        d.showSeconds = showSeconds
        d.markerStyle = markerStyle.model
        d.handShape = handShape.model
        d.dotShape = dotShape.model
        d.digitalFont = digitalFont.model
        d.use24Hour = use24Hour
        d.showDate = showDate
        d.showWeekday = showWeekday
        d.customText = customText ?? ""
        return d
    }
}

// MARK: - Timeline

struct ClockEntry: TimelineEntry {
    let date: Date
    let design: ClockFaceDesign
}

struct ClockProvider: AppIntentTimelineProvider {
    typealias Entry = ClockEntry
    typealias Intent = ConfigureClockIntent

    func placeholder(in context: Context) -> ClockEntry {
        ClockEntry(date: Date(), design: .default)
    }

    func snapshot(for configuration: ConfigureClockIntent, in context: Context) async -> ClockEntry {
        ClockEntry(date: Date(), design: configuration.makeDesign())
    }

    func timeline(for configuration: ConfigureClockIntent, in context: Context) async -> Timeline<ClockEntry> {
        let design = configuration.makeDesign()
        let calendar = Calendar.current
        let now = Date()
        // 現在を分境界（00秒）に丸める
        let comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let startMinute = calendar.date(from: comps) ?? now

        var entries: [ClockEntry] = []
        for offset in 0..<60 {
            if let date = calendar.date(byAdding: .minute, value: offset, to: startMinute) {
                entries.append(ClockEntry(date: date, design: design))
            }
        }
        return Timeline(entries: entries, policy: .atEnd)
    }
}

// MARK: - View & Widget

struct ClockWidgetEntryView: View {
    var entry: ClockEntry

    var body: some View {
        ClockFaceView(design: entry.design, date: entry.date)
    }
}

struct ClockWidget: Widget {
    let kind = "ClockWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigureClockIntent.self, provider: ClockProvider()) { entry in
            ClockWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(hex: entry.design.backgroundHex)
                }
        }
        .configurationDisplayName("Clock Widget")
        .description("カスタム時計ウィジェット")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
