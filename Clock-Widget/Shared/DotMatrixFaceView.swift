import SwiftUI

/// ドット時計（5x7 ドットフォント）の前景描画ビュー。
///
/// 背景は別担当が描くため、このビューは前景（点灯／消灯ドット）のみを
/// `Canvas` 上に描画する。背景は塗らない（clear）。
struct DotMatrixFaceView: View {
    let design: ClockFaceDesign
    let date: Date

    var body: some View {
        GeometryReader { _ in
            Canvas { context, size in
                // 利用可能領域いっぱいにフィット（正方形に制限せず最大活用）。
                let margin = min(size.width, size.height) * 0.04
                let rect = CGRect(x: margin, y: margin,
                                  width: max(0, size.width - margin * 2),
                                  height: max(0, size.height - margin * 2))
                DotFont.draw(timeString,
                             in: &context,
                             rect: rect,
                             dotShape: design.dotShape,
                             occupancy: design.dotSize,
                             litColor: design.markerColor,
                             glow: design.dotGlow)
            }
        }
    }

    // MARK: - 時刻文字列

    private var timeString: String {
        let cal = Calendar.current
        let comps = cal.dateComponents([.hour, .minute, .second], from: date)
        let hour24 = comps.hour ?? 0
        let minute = comps.minute ?? 0
        let second = comps.second ?? 0

        let hourText: String
        if design.use24Hour {
            hourText = String(format: "%02d", hour24)
        } else {
            var h = hour24 % 12
            if h == 0 { h = 12 }
            hourText = String(h) // 先頭ゼロ無し
        }

        var result = "\(hourText):\(String(format: "%02d", minute))"
        if design.showSeconds {
            result += ":\(String(format: "%02d", second))"
        }
        return result
    }
}

// MARK: - 5x7 ドットフォント（数字・記号・英大文字）

/// 数字・コロン・スラッシュ・英大文字を 5x7 のビットマップで表現する簡易フォント。
/// 時刻だけでなく、日付・曜日などの補助情報のドット描画にも再利用する。
enum DotFont {
    static let rowCount = 7
    private static let glyphWidth = 5
    private static let gap = 1 // 文字間の空き列数

    // MARK: 行列展開

    /// 文字列をドット行列（[row][col] の Bool）に展開する。
    static func matrix(for text: String) -> [[Bool]] {
        let glyphs = text.map { glyph(for: $0) }
        guard !glyphs.isEmpty else { return [] }

        var rows: [[Bool]] = Array(repeating: [], count: rowCount)
        for (index, glyph) in glyphs.enumerated() {
            for r in 0..<rowCount {
                for ch in glyph[r] {
                    rows[r].append(ch == "1")
                }
                if index < glyphs.count - 1 {
                    rows[r].append(contentsOf: Array(repeating: false, count: gap))
                }
            }
        }
        return rows
    }

    // MARK: 共通描画

    /// 指定矩形に文字列をドットで描画する。時刻・補助情報の両方で使用。
    /// - occupancy: セルに対するドット占有率（0.3〜1.0）
    static func draw(_ text: String,
                     in context: inout GraphicsContext,
                     rect: CGRect,
                     dotShape: DotShape,
                     occupancy: CGFloat,
                     litColor: Color,
                     glow: Bool) {
        let matrix = matrix(for: text)
        let rows = rowCount
        let cols = matrix.first?.count ?? 0
        guard rows > 0, cols > 0, rect.width > 0, rect.height > 0 else { return }

        // セル一辺。縦横どちらかに収まるよう自動調整。
        let cellSize = min(rect.width / CGFloat(cols), rect.height / CGFloat(rows))
        let gridW = cellSize * CGFloat(cols)
        let gridH = cellSize * CGFloat(rows)
        let originX = rect.minX + (rect.width - gridW) / 2
        let originY = rect.minY + (rect.height - gridH) / 2

        let occ = min(max(occupancy, 0.3), 1.0) * 0.92
        let dotSize = cellSize * occ
        let inset = (cellSize - dotSize) / 2

        let litC = litColor
        // 消灯マスは点灯色に関わらず固定の灰色
        let dimC = Color.gray.opacity(0.3)

        func cellRect(_ r: Int, _ c: Int) -> CGRect {
            CGRect(x: originX + CGFloat(c) * cellSize + inset,
                   y: originY + CGFloat(r) * cellSize + inset,
                   width: dotSize, height: dotSize)
        }

        func dotPath(_ rect: CGRect) -> Path {
            switch dotShape {
            case .circle:        return Path(ellipseIn: rect)
            case .roundedSquare: return Path(roundedRect: rect, cornerRadius: rect.width * 0.28)
            case .square:        return Path(rect)
            }
        }

        // 発光風レイヤ（控えめ）
        if glow {
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: cellSize * 0.35))
                for r in 0..<rows {
                    for c in 0..<cols where matrix[r][c] {
                        let rr = cellRect(r, c).insetBy(dx: -cellSize * 0.18, dy: -cellSize * 0.18)
                        layer.fill(dotPath(rr), with: .color(litC.opacity(0.55)))
                    }
                }
            }
        }

        // ベース（消灯→点灯）
        for r in 0..<rows {
            for c in 0..<cols {
                context.fill(dotPath(cellRect(r, c)),
                             with: .color(matrix[r][c] ? litC : dimC))
            }
        }
    }

    // MARK: グリフ定義

    /// 1文字分の 7 行ビットマップ（各行 5 文字の "0"/"1"）。未対応文字は空白。
    private static func glyph(for ch: Character) -> [String] {
        switch ch {
        case "0": return ["01110", "10001", "10011", "10101", "11001", "10001", "01110"]
        case "1": return ["00100", "01100", "00100", "00100", "00100", "00100", "01110"]
        case "2": return ["01110", "10001", "00001", "00010", "00100", "01000", "11111"]
        case "3": return ["11111", "00010", "00100", "00010", "00001", "10001", "01110"]
        case "4": return ["00010", "00110", "01010", "10010", "11111", "00010", "00010"]
        case "5": return ["11111", "10000", "11110", "00001", "00001", "10001", "01110"]
        case "6": return ["00110", "01000", "10000", "11110", "10001", "10001", "01110"]
        case "7": return ["11111", "00001", "00010", "00100", "01000", "01000", "01000"]
        case "8": return ["01110", "10001", "10001", "01110", "10001", "10001", "01110"]
        case "9": return ["01110", "10001", "10001", "01111", "00001", "00010", "01100"]
        case ":": return ["00000", "00100", "00100", "00000", "00100", "00100", "00000"]
        case "/": return ["00001", "00001", "00010", "00100", "01000", "10000", "10000"]
        case "-": return ["00000", "00000", "00000", "11111", "00000", "00000", "00000"]
        case ".": return ["00000", "00000", "00000", "00000", "00000", "00110", "00110"]
        case " ": return ["00000", "00000", "00000", "00000", "00000", "00000", "00000"]
        case "A": return ["01110", "10001", "10001", "11111", "10001", "10001", "10001"]
        case "B": return ["11110", "10001", "10001", "11110", "10001", "10001", "11110"]
        case "C": return ["01110", "10001", "10000", "10000", "10000", "10001", "01110"]
        case "D": return ["11100", "10010", "10001", "10001", "10001", "10010", "11100"]
        case "E": return ["11111", "10000", "10000", "11110", "10000", "10000", "11111"]
        case "F": return ["11111", "10000", "10000", "11110", "10000", "10000", "10000"]
        case "G": return ["01110", "10001", "10000", "10111", "10001", "10001", "01111"]
        case "H": return ["10001", "10001", "10001", "11111", "10001", "10001", "10001"]
        case "I": return ["01110", "00100", "00100", "00100", "00100", "00100", "01110"]
        case "J": return ["00111", "00010", "00010", "00010", "00010", "10010", "01100"]
        case "K": return ["10001", "10010", "10100", "11000", "10100", "10010", "10001"]
        case "L": return ["10000", "10000", "10000", "10000", "10000", "10000", "11111"]
        case "M": return ["10001", "11011", "10101", "10101", "10001", "10001", "10001"]
        case "N": return ["10001", "10001", "11001", "10101", "10011", "10001", "10001"]
        case "O": return ["01110", "10001", "10001", "10001", "10001", "10001", "01110"]
        case "P": return ["11110", "10001", "10001", "11110", "10000", "10000", "10000"]
        case "Q": return ["01110", "10001", "10001", "10001", "10101", "10010", "01101"]
        case "R": return ["11110", "10001", "10001", "11110", "10100", "10010", "10001"]
        case "S": return ["01111", "10000", "10000", "01110", "00001", "00001", "11110"]
        case "T": return ["11111", "00100", "00100", "00100", "00100", "00100", "00100"]
        case "U": return ["10001", "10001", "10001", "10001", "10001", "10001", "01110"]
        case "V": return ["10001", "10001", "10001", "10001", "10001", "01010", "00100"]
        case "W": return ["10001", "10001", "10001", "10101", "10101", "11011", "10001"]
        case "X": return ["10001", "10001", "01010", "00100", "01010", "10001", "10001"]
        case "Y": return ["10001", "10001", "01010", "00100", "00100", "00100", "00100"]
        case "Z": return ["11111", "00001", "00010", "00100", "01000", "10000", "11111"]
        default:  return Array(repeating: String(repeating: "0", count: glyphWidth), count: rowCount)
        }
    }
}
