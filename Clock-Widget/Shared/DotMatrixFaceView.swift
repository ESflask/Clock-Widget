import SwiftUI

/// ドット時計（5x7 ドットフォント）の前景描画ビュー。
///
/// 背景は別担当が描くため、このビューは前景（点灯／消灯ドット）のみを
/// `Canvas` 上に描画する。背景は塗らない（clear）。
struct DotMatrixFaceView: View {
    let design: ClockFaceDesign
    let date: Date

    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                draw(in: &context, size: size)
            }
        }
    }

    // MARK: - 描画本体

    private func draw(in context: inout GraphicsContext, size: CGSize) {
        let matrix = DotFont.matrix(for: timeString)
        let rows = DotFont.rowCount
        let cols = matrix.count > 0 ? matrix[0].count : 0
        guard rows > 0, cols > 0 else { return }

        // 全体を正方形領域に中央寄せでフィット
        let side = min(size.width, size.height)
        let originSquareX = (size.width - side) / 2
        let originSquareY = (size.height - side) / 2

        // 周囲に少し余白を取る
        let margin = side * 0.06
        let availW = side - margin * 2
        let availH = side - margin * 2

        // セル（ドット1個分の正方領域）の一辺。横が詰まる場合も自動で縮む。
        let cellSize = min(availW / CGFloat(cols), availH / CGFloat(rows))

        let gridW = cellSize * CGFloat(cols)
        let gridH = cellSize * CGFloat(rows)
        let originX = originSquareX + (side - gridW) / 2
        let originY = originSquareY + (side - gridH) / 2

        // ドット占有率（0.3〜1.0）。セルからわずかに内側に収める。
        let occupancy = CGFloat(min(max(design.dotSize, 0.3), 1.0)) * 0.92
        let dotSize = cellSize * occupancy
        let inset = (cellSize - dotSize) / 2

        let litColor = design.markerColor
        let dimColor = litColor.opacity(0.15)

        func cellRect(_ r: Int, _ c: Int) -> CGRect {
            CGRect(
                x: originX + CGFloat(c) * cellSize + inset,
                y: originY + CGFloat(r) * cellSize + inset,
                width: dotSize,
                height: dotSize
            )
        }

        func dotPath(in rect: CGRect) -> Path {
            switch design.dotShape {
            case .circle:
                return Path(ellipseIn: rect)
            case .roundedSquare:
                return Path(roundedRect: rect, cornerRadius: rect.width * 0.28)
            case .square:
                return Path(rect)
            }
        }

        // --- 発光風レイヤ（控えめ）---
        if design.dotGlow {
            context.drawLayer { layer in
                layer.addFilter(.blur(radius: cellSize * 0.35))
                for r in 0..<rows {
                    for c in 0..<cols where matrix[r][c] {
                        // 少し大きめのドットを低不透明度で重ねて滲ませる
                        let rect = cellRect(r, c).insetBy(dx: -cellSize * 0.18,
                                                          dy: -cellSize * 0.18)
                        layer.fill(dotPath(in: rect), with: .color(litColor.opacity(0.55)))
                    }
                }
            }
        }

        // --- ベースのドット（消灯→点灯の順で描画）---
        for r in 0..<rows {
            for c in 0..<cols {
                let rect = cellRect(r, c)
                let path = dotPath(in: rect)
                context.fill(path, with: .color(matrix[r][c] ? litColor : dimColor))
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

// MARK: - 5x7 ドットフォント

/// 数字とコロンを 5x7 のビットマップで表現する簡易フォント。
private enum DotFont {
    static let rowCount = 7
    private static let glyphWidth = 5
    private static let gap = 1 // 文字間の空き列数

    /// 文字列をドット行列（[row][col] の Bool）に展開する。
    static func matrix(for text: String) -> [[Bool]] {
        let glyphs = text.map { glyph(for: $0) }
        guard !glyphs.isEmpty else { return [] }

        var rows: [[Bool]] = Array(repeating: [], count: rowCount)
        for (index, glyph) in glyphs.enumerated() {
            for r in 0..<rowCount {
                let pattern = glyph[r]
                for ch in pattern {
                    rows[r].append(ch == "1")
                }
                // 文字間ギャップ（最後の文字の後ろには付けない）
                if index < glyphs.count - 1 {
                    rows[r].append(contentsOf: Array(repeating: false, count: gap))
                }
            }
        }
        return rows
    }

    /// 1文字分の 7 行ビットマップ（各行 5 文字の "0"/"1"）。
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
        default:  return Array(repeating: String(repeating: "0", count: glyphWidth), count: rowCount)
        }
    }
}
