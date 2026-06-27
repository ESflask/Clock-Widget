import SwiftUI

/// アナログ時計の前景（マーカー・針・中心キャップ）を描画するビュー。
///
/// 背景は別担当が描画するため、ここでは塗らない（clear）。
/// 与えられた `date` を静的に描画し、タイマー等の動的処理は持たない。
struct AnalogFaceView: View {
    let design: ClockFaceDesign
    let date: Date

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            Canvas { context, size in
                // 利用領域を正方形に中央寄せ
                let origin = CGPoint(
                    x: (size.width - side) / 2,
                    y: (size.height - side) / 2
                )
                let center = CGPoint(x: origin.x + side / 2,
                                     y: origin.y + side / 2)
                let radius = side / 2

                drawMarkers(context: context, center: center, radius: radius)
                drawHands(context: context, center: center, radius: radius)
                drawCenterCap(context: context, center: center, radius: radius)
            }
            // Canvas は与えられたサイズいっぱいに広がるので、外側の余白は気にしない
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // MARK: - マーカー

    private func drawMarkers(context: GraphicsContext,
                             center: CGPoint,
                             radius: CGFloat) {
        guard design.markerStyle != .none else {
            // .none でも、密度が .sixty のときは細かい分目盛を描く意匠もあり得るが、
            // 「描かない」を優先する。
            return
        }

        // 現在の「時」位置（0...11）。useAccent 強調に使用。
        let cal = Calendar.current
        let hour12 = cal.component(.hour, from: date) % 12

        switch design.markerStyle {
        case .dots, .lines:
            drawTickMarkers(context: context,
                            center: center,
                            radius: radius,
                            hour12: hour12)
        case .arabic, .roman:
            drawNumeralMarkers(context: context,
                               center: center,
                               radius: radius,
                               hour12: hour12)
        case .none:
            break
        }
    }

    /// ドット／線のマーカー。密度に応じて個数を変える。
    private func drawTickMarkers(context: GraphicsContext,
                                 center: CGPoint,
                                 radius: CGFloat,
                                 hour12: Int) {
        switch design.markerDensity {
        case .four:
            // 3/6/9/12 のみ → 60分割換算で 15 ごと
            for tick in stride(from: 0, to: 60, by: 15) {
                drawTick(context: context, center: center, radius: radius,
                         tick: tick, major: true, hour12: hour12)
            }
        case .twelve:
            for tick in stride(from: 0, to: 60, by: 5) {
                drawTick(context: context, center: center, radius: radius,
                         tick: tick, major: true, hour12: hour12)
            }
        case .sixty:
            for tick in 0..<60 {
                let major = (tick % 5 == 0)
                drawTick(context: context, center: center, radius: radius,
                         tick: tick, major: major, hour12: hour12)
            }
        }
    }

    /// 60分割スケール上の 1 目盛を描く。`tick` は 0...59。
    private func drawTick(context: GraphicsContext,
                          center: CGPoint,
                          radius: CGFloat,
                          tick: Int,
                          major: Bool,
                          hour12: Int) {
        let angle = angleForTick(tick)              // 12時=上 を 0 とする時計回り角度
        let isHourPosition = (tick % 5 == 0)
        let hourIndex = (tick / 5) % 12             // この目盛が指す「時」位置

        let color = markerColor(isHourPosition: isHourPosition,
                                hourIndex: hourIndex,
                                hour12: hour12)

        switch design.markerStyle {
        case .dots:
            let dotRadius = (major ? radius * 0.035 : radius * 0.018)
            let outer = radius * 0.88
            let p = point(from: center, angle: angle, distance: outer)
            let rect = CGRect(x: p.x - dotRadius, y: p.y - dotRadius,
                              width: dotRadius * 2, height: dotRadius * 2)
            context.fill(Path(ellipseIn: rect), with: .color(color))

        case .lines:
            let lineWidth = (major ? radius * 0.025 : radius * 0.012)
            let outer = radius * 0.94
            let length = (major ? radius * 0.12 : radius * 0.06)
            let inner = outer - length
            let p1 = point(from: center, angle: angle, distance: inner)
            let p2 = point(from: center, angle: angle, distance: outer)
            var path = Path()
            path.move(to: p1)
            path.addLine(to: p2)
            context.stroke(path, with: .color(color),
                           style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

        default:
            break
        }
    }

    /// 数字（アラビア／ローマ）マーカー。常に 12 個。
    /// 密度が .sixty のときは細かい分目盛の線を加える。
    private func drawNumeralMarkers(context: GraphicsContext,
                                    center: CGPoint,
                                    radius: CGFloat,
                                    hour12: Int) {
        // 補助の分目盛（.sixty のときのみ）
        if design.markerDensity == .sixty {
            for tick in 0..<60 where tick % 5 != 0 {
                let angle = angleForTick(tick)
                let outer = radius * 0.96
                let inner = outer - radius * 0.04
                let p1 = point(from: center, angle: angle, distance: inner)
                let p2 = point(from: center, angle: angle, distance: outer)
                var path = Path()
                path.move(to: p1)
                path.addLine(to: p2)
                context.stroke(path, with: .color(design.markerColor),
                               style: StrokeStyle(lineWidth: radius * 0.008, lineCap: .round))
            }
        }

        let fontSize = radius * 0.16
        let distance = radius * 0.78

        for hourPos in 1...12 {
            // hourPos: 1...12（12=上）
            // 60分割スケール換算: 12時=tick0
            let tick = (hourPos % 12) * 5
            let angle = angleForTick(tick)
            let p = point(from: center, angle: angle, distance: distance)

            let hourIndex = hourPos % 12
            let color = markerColor(isHourPosition: true,
                                    hourIndex: hourIndex,
                                    hour12: hour12)

            let label = (design.markerStyle == .roman)
                ? Self.romanNumerals[hourPos - 1]
                : String(hourPos)

            let text = Text(label)
                .font(.system(size: fontSize, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            context.draw(text, at: p, anchor: .center)
        }
    }

    /// マーカー色の決定。useAccent かつ現在時位置なら accentColor。
    private func markerColor(isHourPosition: Bool,
                             hourIndex: Int,
                             hour12: Int) -> Color {
        if design.useAccent, isHourPosition, hourIndex == hour12 {
            return design.accentColor
        }
        return design.markerColor
    }

    // MARK: - 針

    private func drawHands(context: GraphicsContext,
                           center: CGPoint,
                           radius: CGFloat) {
        let cal = Calendar.current
        let h = CGFloat(cal.component(.hour, from: date) % 12)
        let m = CGFloat(cal.component(.minute, from: date))
        let s = CGFloat(cal.component(.second, from: date))

        // 角度（12時方向=0、時計回り、ラジアン）
        let hourAngle = (h + m / 60) / 12 * 2 * .pi
        let minuteAngle = (m + s / 60) / 60 * 2 * .pi
        let secondAngle = s / 60 * 2 * .pi

        // 時針（短・太）
        drawHand(context: context, center: center, radius: radius,
                 angle: hourAngle,
                 length: radius * 0.52,
                 baseWidth: radius * 0.045,
                 color: design.hourHandColor)

        // 分針（長・中）
        drawHand(context: context, center: center, radius: radius,
                 angle: minuteAngle,
                 length: radius * 0.78,
                 baseWidth: radius * 0.030,
                 color: design.minuteHandColor)

        // 秒針（細）
        if design.showSeconds {
            drawHand(context: context, center: center, radius: radius,
                     angle: secondAngle,
                     length: radius * 0.86,
                     baseWidth: radius * 0.014,
                     color: design.secondHandColor)
        }
    }

    private func drawHand(context: GraphicsContext,
                          center: CGPoint,
                          radius: CGFloat,
                          angle: CGFloat,
                          length: CGFloat,
                          baseWidth: CGFloat,
                          color: Color) {
        // 少し中心の反対側へ伸ばすテール
        let tail = radius * 0.10
        let tip = point(from: center, angle: angle, distance: length)
        let back = point(from: center, angle: angle + .pi, distance: tail)

        switch design.handShape {
        case .line:
            var path = Path()
            path.move(to: back)
            path.addLine(to: tip)
            context.stroke(path, with: .color(color),
                           style: StrokeStyle(lineWidth: baseWidth, lineCap: .butt))

        case .rounded:
            var path = Path()
            path.move(to: back)
            path.addLine(to: tip)
            context.stroke(path, with: .color(color),
                           style: StrokeStyle(lineWidth: baseWidth, lineCap: .round))

        case .tapered:
            // 根元太→先端細の台形を Path 塗りで表現
            let halfBase = baseWidth
            let halfTip = baseWidth * 0.18
            // 針方向に垂直な単位ベクトル
            let perp = angle + .pi / 2
            let dx = cos(perp)
            let dy = sin(perp)

            let baseL = CGPoint(x: back.x + dx * halfBase, y: back.y + dy * halfBase)
            let baseR = CGPoint(x: back.x - dx * halfBase, y: back.y - dy * halfBase)
            let tipL = CGPoint(x: tip.x + dx * halfTip, y: tip.y + dy * halfTip)
            let tipR = CGPoint(x: tip.x - dx * halfTip, y: tip.y - dy * halfTip)

            var path = Path()
            path.move(to: baseL)
            path.addLine(to: tipL)
            path.addLine(to: tipR)
            path.addLine(to: baseR)
            path.closeSubpath()
            context.fill(path, with: .color(color))
        }
    }

    // MARK: - 中心キャップ

    private func drawCenterCap(context: GraphicsContext,
                               center: CGPoint,
                               radius: CGFloat) {
        guard design.showCenterCap else { return }
        let capRadius = radius * 0.04
        let rect = CGRect(x: center.x - capRadius, y: center.y - capRadius,
                          width: capRadius * 2, height: capRadius * 2)
        let color = design.tintColor
        context.fill(Path(ellipseIn: rect), with: .color(color))
    }

    // MARK: - ジオメトリ補助

    /// 60分割スケール上の `tick`（0...59）に対応する角度（12時=0、時計回り、ラジアン）。
    private func angleForTick(_ tick: Int) -> CGFloat {
        CGFloat(tick) / 60 * 2 * .pi
    }

    /// 中心から、12時を 0 とする時計回り角度・距離の点を返す。
    private func point(from center: CGPoint,
                       angle: CGFloat,
                       distance: CGFloat) -> CGPoint {
        // 12時方向=上(-y)、時計回り。
        let a = CGFloat(angle)
        let x = center.x + sin(a) * distance
        let y = center.y - cos(a) * distance
        return CGPoint(x: x, y: y)
    }

    // ローマ数字 I...XII
    private static let romanNumerals: [String] = [
        "I", "II", "III", "IV", "V", "VI",
        "VII", "VIII", "IX", "X", "XI", "XII"
    ]
}
