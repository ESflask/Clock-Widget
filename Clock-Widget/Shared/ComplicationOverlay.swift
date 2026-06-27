import SwiftUI

/// 盤面に重ねる付加情報（E: 日付・曜日・ひとこと）の透明レイヤ。
/// 時計本体は描かず、情報の重ね表示のみを行う。
/// すべて非表示なら何も出さない。
struct ComplicationOverlay: View {
    let design: ClockFaceDesign
    let date: Date

    var body: some View {
        if hasContent {
            VStack {
                infoStack
                Spacer(minLength: 0)
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            EmptyView()
        }
    }

    // MARK: - 情報スタック

    private var infoStack: some View {
        VStack(spacing: 2) {
            if design.showDate || design.showWeekday {
                Text(dateLine)
                    .font(.caption)
            }
            if !design.customText.isEmpty {
                Text(design.customText)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .foregroundStyle(design.markerColor)
    }

    // MARK: - 表示判定・文字列

    private var hasContent: Bool {
        design.showDate || design.showWeekday || !design.customText.isEmpty
    }

    /// 日付・曜日を1行に組み立てる（例: "6/27 金"）。
    private var dateLine: String {
        var parts: [String] = []
        let cal = Calendar.current

        if design.showDate {
            let comps = cal.dateComponents([.month, .day], from: date)
            parts.append("\(comps.month ?? 0)/\(comps.day ?? 0)")
        }
        if design.showWeekday {
            parts.append(weekdaySymbol)
        }
        return parts.joined(separator: " ")
    }

    /// ロケールに応じた短い曜日表記（例: "金"）。
    private var weekdaySymbol: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.shortWeekdaySymbols ?? []
        let weekday = Calendar.current.component(.weekday, from: date) // 1 = 日曜
        let index = weekday - 1
        guard index >= 0, index < symbols.count else { return "" }
        return symbols[index]
    }
}
