import WidgetKit
import SwiftUI
import AppIntents

// MARK: - 設定用 AppEnum（ウィジェット「編集」画面のピッカーに表示）
// App Group を使わず、ウィジェット自身の構成（iOS が個別保存）でデザインを決める。
// 無料(Personal Team)アカウントの実機でもカスタマイズ可能。
// ※ typeDisplayRepresentation / caseDisplayRepresentations は AppIntents のメタデータ抽出が
//   確実に拾えるよう「格納プロパティ(static let)」で定義する（計算プロパティだと実行時に
//   "No AppIntent / Failed to create LinkAction" を招くことがある）。

/// 色はカラーホイールを置けないため定義済みパレットから選ぶ。
enum ColorChoice: String, AppEnum {
    case white, black, gray, red, orange, yellow, green, mint, blue, indigo, purple, pink

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "色"
    static let caseDisplayRepresentations: [ColorChoice: DisplayRepresentation] = [
        .white: "ホワイト", .black: "ブラック", .gray: "グレー", .red: "レッド",
        .orange: "オレンジ", .yellow: "イエロー", .green: "グリーン", .mint: "ミント",
        .blue: "ブルー", .indigo: "インディゴ", .purple: "パープル", .pink: "ピンク",
    ]

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
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "スタイル"
    static let caseDisplayRepresentations: [StyleChoice: DisplayRepresentation] = [
        .analog: "アナログ", .dotMatrix: "ドット時計", .digital: "デジタル",
    ]
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
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "背景の種類"
    static let caseDisplayRepresentations: [BackgroundKindChoice: DisplayRepresentation] = [
        .solid: "単色", .linearGradient: "線形グラデ", .radialGradient: "放射グラデ",
    ]
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
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "マーカー"
    static let caseDisplayRepresentations: [MarkerStyleChoice: DisplayRepresentation] = [
        .dots: "ドット", .lines: "線", .arabic: "数字", .roman: "ローマ", .none: "なし",
    ]
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
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "針の形"
    static let caseDisplayRepresentations: [HandShapeChoice: DisplayRepresentation] = [
        .line: "直線", .tapered: "テーパー", .rounded: "丸み",
    ]
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
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "ドット形状"
    static let caseDisplayRepresentations: [DotShapeChoice: DisplayRepresentation] = [
        .circle: "円", .roundedSquare: "角丸", .square: "四角",
    ]
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
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "フォント"
    static let caseDisplayRepresentations: [DigitalFontChoice: DisplayRepresentation] = [
        .system: "システム", .rounded: "丸ゴ", .monospaced: "等幅", .serif: "セリフ",
    ]
    var model: DigitalFont {
        switch self {
        case .system:     return .system
        case .rounded:    return .rounded
        case .monospaced: return .monospaced
        case .serif:      return .serif
        }
    }
}

/// 盤面の相対サイズ（表示領域に対する縮尺）。
enum FaceSizeChoice: String, AppEnum {
    case small, medium, large, full

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "盤面サイズ"
    static let caseDisplayRepresentations: [FaceSizeChoice: DisplayRepresentation] = [
        .small: "小", .medium: "中", .large: "大", .full: "最大",
    ]
    var scale: Double {
        switch self {
        case .small:  return 0.6
        case .medium: return 0.75
        case .large:  return 0.9
        case .full:   return 1.0
        }
    }
}

/// デザインの取得元。アプリ編集に追従するか、ウィジェット個別設定にするか。
enum DesignSource: String, AppEnum {
    case followApp
    case custom

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "デザイン元"
    static let caseDisplayRepresentations: [DesignSource: DisplayRepresentation] = [
        .followApp: "アプリの設定に従う", .custom: "このウィジェットで個別設定",
    ]
}

// MARK: - ウィジェット構成 Intent（「ウィジェットを編集」画面）

struct ConfigureClockIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "時計をカスタマイズ"
    static let description = IntentDescription("ウィジェットの時計デザインを設定します。")

    @Parameter(title: "デザイン元", default: .followApp) var source: DesignSource

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
    @Parameter(title: "盤面サイズ", default: .full) var faceSize: FaceSizeChoice

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
        d.faceScale = faceSize.scale
        return d
    }

    /// ウィジェットに表示するデザインを決定する。
    /// - followApp: アプリ(App Group)で編集した現在デザインに追従。
    /// - custom: 上の各パラメータで個別設定。
    func resolvedDesign() -> ClockFaceDesign {
        switch source {
        case .followApp: return ClockFaceStore.load()
        case .custom:    return makeDesign()
        }
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
        ClockEntry(date: Date(), design: configuration.resolvedDesign())
    }

    func timeline(for configuration: ConfigureClockIntent, in context: Context) async -> Timeline<ClockEntry> {
        let design = configuration.resolvedDesign()
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
        // 背景は containerBackground 側で全面に敷くため、ここは前景（盤面）のみ。
        ClockFaceContent(design: entry.design, date: entry.date)
    }
}

struct ClockWidget: Widget {
    let kind = "ClockWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigureClockIntent.self, provider: ClockProvider()) { entry in
            ClockWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    // 背景（単色/グラデ・不透明度）をウィジェット全体に敷く
                    ClockBackgroundView(design: entry.design)
                }
        }
        .configurationDisplayName("Clock Widget")
        .description("カスタム時計ウィジェット")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
        .contentMarginsDisabled() // 既定の余白を無くし、時計盤をウィジェット端まで最大化
    }
}
