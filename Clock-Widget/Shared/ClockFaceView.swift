import SwiftUI

/// A pure, static clock-face renderer for the Clock-Widget.
///
/// `ClockFaceView` draws the time described by `date` according to `design`.
/// It is intentionally free of timers / `onReceive` / animation so it can be
/// used safely inside WidgetKit timeline entries, where each entry simply
/// renders one fixed `Date`.
struct ClockFaceView: View {
    let design: ClockFaceDesign
    let date: Date

    var body: some View {
        GeometryReader { proxy in
            // Constrain everything to a centered square so systemSmall /
            // systemMedium (and any other aspect ratio) never distort the face.
            let side = min(proxy.size.width, proxy.size.height)

            ZStack {
                Color(hex: design.backgroundHex)

                content
                    .frame(width: side, height: side)
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // center the square
            }
        }
    }

    // MARK: - Style dispatch

    @ViewBuilder
    private var content: some View {
        switch design.style {
        case .analog:
            analogFace
        case .dotMatrix:
            dotMatrixFace
        case .digital:
            digitalFace
        }
    }

    // MARK: - Time components

    /// Hour in 12-hour form (0..<12 as a fraction-friendly value), minute, second.
    private var timeParts: (hour12: Double, minute: Double, second: Double) {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .second], from: date)
        let hour = Double(comps.hour ?? 0).truncatingRemainder(dividingBy: 12)
        let minute = Double(comps.minute ?? 0)
        let second = Double(comps.second ?? 0)
        return (hour, minute, second)
    }

    /// 24-hour hour value (used by the digital face which respects HH).
    private var hour24: Int {
        Calendar.current.component(.hour, from: date)
    }

    // MARK: - Analog

    private var analogFace: some View {
        let tint = Color(hex: design.tintHex)
        let parts = timeParts

        return Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            // Inset a little so the outermost stroke isn't clipped.
            let r = radius * 0.94

            // 12 hour markers around the dial.
            for tick in 0..<12 {
                let angle = Angle.degrees(Double(tick) / 12.0 * 360.0).radians - .pi / 2
                let outer = CGPoint(x: center.x + cos(angle) * r,
                                    y: center.y + sin(angle) * r)
                let inner = CGPoint(x: center.x + cos(angle) * (r * 0.86),
                                    y: center.y + sin(angle) * (r * 0.86))
                var path = Path()
                path.move(to: inner)
                path.addLine(to: outer)
                context.stroke(path,
                               with: .color(tint.opacity(0.85)),
                               lineWidth: max(1, radius * 0.025))
            }

            // Angles: 12 o'clock = 0deg, clockwise. Convert to radians offset by -90deg.
            let hourAngle = (parts.hour12 + parts.minute / 60.0) / 12.0 * 360.0
            let minuteAngle = (parts.minute + parts.second / 60.0) / 60.0 * 360.0
            let secondAngle = parts.second / 60.0 * 360.0

            func hand(angleDegrees: Double, length: CGFloat, width: CGFloat, color: Color) {
                let a = CGFloat(Angle.degrees(angleDegrees).radians - .pi / 2)
                let end = CGPoint(x: center.x + cos(a) * length,
                                  y: center.y + sin(a) * length)
                var path = Path()
                path.move(to: center)
                path.addLine(to: end)
                context.stroke(path,
                               with: .color(color),
                               style: StrokeStyle(lineWidth: width, lineCap: .round))
            }

            // Hour hand (short, thick).
            hand(angleDegrees: hourAngle, length: r * 0.55, width: max(2, radius * 0.06), color: tint)
            // Minute hand (long, medium).
            hand(angleDegrees: minuteAngle, length: r * 0.82, width: max(1.5, radius * 0.04), color: tint)
            // Second hand only when requested (widgets update per-minute, so it's optional).
            if design.showSeconds {
                hand(angleDegrees: secondAngle, length: r * 0.88, width: max(1, radius * 0.02), color: tint.opacity(0.8))
            }

            // Center cap.
            let capR = max(2, radius * 0.05)
            let capRect = CGRect(x: center.x - capR, y: center.y - capR, width: capR * 2, height: capR * 2)
            context.fill(Path(ellipseIn: capRect), with: .color(tint))
        }
        .padding(4)
    }

    // MARK: - Dot matrix

    /// A 5x7 dot-font for the digits 0-9 plus a colon glyph.
    /// Each digit is 5 columns wide and 7 rows tall; bit set => lit dot.
    private static let dotFont: [Character: [String]] = [
        "0": ["01110", "10001", "10011", "10101", "11001", "10001", "01110"],
        "1": ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
        "2": ["01110", "10001", "00001", "00010", "00100", "01000", "11111"],
        "3": ["11111", "00010", "00100", "00010", "00001", "10001", "01110"],
        "4": ["00010", "00110", "01010", "10010", "11111", "00010", "00010"],
        "5": ["11111", "10000", "11110", "00001", "00001", "10001", "01110"],
        "6": ["00110", "01000", "10000", "11110", "10001", "10001", "01110"],
        "7": ["11111", "00001", "00010", "00100", "01000", "01000", "01000"],
        "8": ["01110", "10001", "10001", "01110", "10001", "10001", "01110"],
        "9": ["01110", "10001", "10001", "01111", "00001", "00010", "01100"],
        ":": ["00000", "00100", "00100", "00000", "00000", "00100", "00100"]
    ]

    private var dotMatrixFace: some View {
        let tint = Color(hex: design.tintHex)
        // HH:MM in zero-padded 24-hour form.
        let text = String(format: "%02d:%02d", hour24, Int(timeParts.minute))

        return Canvas { context, size in
            let glyphs = text.map { ClockFaceView.dotFont[$0] ?? Array(repeating: "00000", count: 7) }
            let glyphCols = 5
            let rows = 7
            let gap = 1                       // empty columns between glyphs
            let totalCols = glyphs.count * glyphCols + (glyphs.count - 1) * gap
            let totalRows = rows

            // Cell size so the whole matrix fits inside the square.
            let cell = min(size.width / CGFloat(totalCols), size.height / CGFloat(totalRows))
            let gridW = cell * CGFloat(totalCols)
            let gridH = cell * CGFloat(totalRows)
            let originX = (size.width - gridW) / 2
            let originY = (size.height - gridH) / 2

            // dotSize (0..1) scales the dot radius within its cell.
            let clampedDot = max(0.2, min(1.0, design.dotSize))
            let dotR = cell * 0.5 * CGFloat(clampedDot) * 0.9

            func drawDot(col: Int, row: Int, lit: Bool) {
                let cx = originX + (CGFloat(col) + 0.5) * cell
                let cy = originY + (CGFloat(row) + 0.5) * cell
                let rect = CGRect(x: cx - dotR, y: cy - dotR, width: dotR * 2, height: dotR * 2)
                let color = lit ? tint : tint.opacity(0.15)
                context.fill(Path(ellipseIn: rect), with: .color(color))
            }

            var colOffset = 0
            for glyph in glyphs {
                for row in 0..<rows {
                    let pattern = Array(glyph[row])
                    for c in 0..<glyphCols {
                        let lit = pattern[c] == "1"
                        drawDot(col: colOffset + c, row: row, lit: lit)
                    }
                }
                colOffset += glyphCols + gap
            }
        }
        .padding(6)
    }

    // MARK: - Digital

    private var digitalFace: some View {
        let tint = Color(hex: design.tintHex)
        let formatter = DateFormatter()
        formatter.dateFormat = design.showSeconds ? "HH:mm:ss" : "HH:mm"
        let text = formatter.string(from: date)

        return Text(text)
            .font(.system(size: 200, weight: .semibold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.05)
            .padding(8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Previews

#Preview("Analog") {
    ClockFaceView(
        design: .init(style: .analog, tintHex: "#FFFFFF", backgroundHex: "#1C1C1E", showSeconds: true, dotSize: 0.7),
        date: .now
    )
    .frame(width: 170, height: 170)
}

#Preview("Dot Matrix") {
    ClockFaceView(
        design: .init(style: .dotMatrix, tintHex: "#34C759", backgroundHex: "#000000", showSeconds: false, dotSize: 0.8),
        date: .now
    )
    .frame(width: 170, height: 170)
}

#Preview("Digital") {
    ClockFaceView(
        design: .init(style: .digital, tintHex: "#0A84FF", backgroundHex: "#1C1C1E", showSeconds: true, dotSize: 0.7),
        date: .now
    )
    .frame(width: 360, height: 170)
}
