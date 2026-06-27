import SwiftUI

/// デジタル時計の文字盤描画（D: デジタル書式）。
/// 与えられた `date` を静的に描画する。背景は塗らない。
struct DigitalFaceView: View {
    let design: ClockFaceDesign
    let date: Date

    var body: some View {
        Text(timeString)
            .font(.system(size: 200,
                          weight: design.fontWeight.weight,
                          design: design.digitalFont.fontDesign))
            .monospacedDigit()
            .foregroundStyle(design.tintColor)
            .lineLimit(1)
            .minimumScaleFactor(0.05)
            .allowsTightening(true)
    }

    // MARK: - 時刻文字列生成

    /// `date` から書式設定に従った時刻文字列を組み立てる。
    private var timeString: String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .second], from: date)
        let hour24 = comps.hour ?? 0
        let minute = comps.minute ?? 0
        let second = comps.second ?? 0

        // 時の値（12h / 24h）
        let displayHour: Int
        if design.use24Hour {
            displayHour = hour24
        } else {
            let h12 = hour24 % 12
            displayHour = h12 == 0 ? 12 : h12
        }

        // 先頭ゼロの有無（時のみ可変、分・秒は常に2桁）
        let hourPart: String
        if design.leadingZero {
            hourPart = String(format: "%02d", displayHour)
        } else {
            hourPart = String(displayHour)
        }

        var result = "\(hourPart):" + String(format: "%02d", minute)
        if design.showSeconds {
            result += ":" + String(format: "%02d", second)
        }

        // 12時間表示かつ AM/PM 併記
        if !design.use24Hour && design.showAMPM {
            result += hour24 < 12 ? " AM" : " PM"
        }

        return result
    }
}
