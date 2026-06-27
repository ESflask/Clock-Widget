import SwiftUI

/// 背景を含まない時計盤の前景（時刻 + 補助情報）。
///
/// 補助情報（日付・曜日・ひとこと）がONのときは、時刻と補助情報を上下に分割配置する。
/// 補助情報の領域は全体の約1/5＝**時刻のおよそ1/4のサイズ**になる。
/// ドット時計スタイルでは補助情報も同じドットフォントで描画する。
/// 盤面は `design.faceScale` で領域に対する縮尺を調整する。
/// ウィジェットでは背景を `containerBackground` 側で全面に敷くため、この前景のみを使う。
struct ClockFaceContent: View {
    let design: ClockFaceDesign
    let date: Date

    private var hasComplication: Bool {
        design.showDate || design.showWeekday || !design.customText.isEmpty
    }

    var body: some View {
        Group {
            if hasComplication {
                GeometryReader { geo in
                    VStack(spacing: geo.size.height * 0.03) {
                        clock
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        complicationView
                            .frame(height: geo.size.height * 0.20)
                            .frame(maxWidth: .infinity)
                    }
                }
            } else {
                clock
            }
        }
        .scaleEffect(max(0.2, min(1.0, design.faceScale)))
    }

    // MARK: - 時刻（スタイル別）

    @ViewBuilder
    private var clock: some View {
        switch design.style {
        case .analog:
            AnalogFaceView(design: design, date: date)
        case .dotMatrix:
            DotMatrixFaceView(design: design, date: date)
        case .digital:
            DigitalFaceView(design: design, date: date)
        }
    }

    // MARK: - 補助情報（時刻の約1/4サイズ）

    @ViewBuilder
    private var complicationView: some View {
        if design.style == .dotMatrix {
            // ドット時計では補助情報もドットで描画
            Canvas { context, size in
                DotFont.draw(complicationString(dots: true),
                             in: &context,
                             rect: CGRect(origin: .zero, size: size),
                             dotShape: design.dotShape,
                             occupancy: design.dotSize,
                             litColor: design.markerColor,
                             glow: false)
            }
        } else {
            Text(complicationString(dots: false))
                .font(.system(size: 200,
                              weight: design.fontWeight.weight,
                              design: design.digitalFont.fontDesign))
                .monospacedDigit()
                .foregroundStyle(design.markerColor)
                .lineLimit(1)
                .minimumScaleFactor(0.01)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - 補助情報の文字列

    /// 曜日・日付・ひとことを1行に連結する。
    /// - dots: ドット描画用（曜日は英大文字、ひとことも大文字化）。
    private func complicationString(dots: Bool) -> String {
        var parts: [String] = []
        if design.showWeekday { parts.append(weekdayString(dots: dots)) }
        if design.showDate { parts.append(dateString()) }
        if !design.customText.isEmpty {
            parts.append(dots ? design.customText.uppercased() : design.customText)
        }
        return parts.joined(separator: " ")
    }

    /// "M/D" 形式の日付。
    private func dateString() -> String {
        let c = Calendar.current.dateComponents([.month, .day], from: date)
        return "\(c.month ?? 0)/\(c.day ?? 0)"
    }

    /// 曜日。ドット用は英大文字3文字、通常はロケール短縮表記。
    private func weekdayString(dots: Bool) -> String {
        let weekday = Calendar.current.component(.weekday, from: date) // 1=Sun...7=Sat
        if dots {
            let en = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            return en[(weekday - 1 + 7) % 7]
        } else {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("EEE")
            return formatter.string(from: date)
        }
    }
}

/// 時計フェイスの合成ビュー（背景込み）。アプリ内のプレビュー等で使用。
struct ClockFaceView: View {
    let design: ClockFaceDesign
    let date: Date

    var body: some View {
        ZStack {
            ClockBackgroundView(design: design)
            ClockFaceContent(design: design, date: date)
        }
        .clipped()
    }
}
