import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// アプリ内のフルスクリーン時計盤。縦横どちらの向きでも中央に正方形フィットで表示する。
/// アプリ内のためライブ更新可能（秒表示時は1秒、それ以外は1分間隔）。
struct FullScreenClockView: View {
    let design: ClockFaceDesign

    @Environment(\.dismiss) private var dismiss
    @State private var showsControls = true
    @State private var nightMode = false

    private var updateInterval: TimeInterval {
        design.showSeconds ? 1.0 : 60.0
    }

    var body: some View {
        ZStack {
            // 背景は画面全体に敷く（盤面本体は中央に正方形フィット）
            ClockBackgroundView(design: design)
                .ignoresSafeArea()

            TimelineView(AlignedTimelineSchedule(interval: updateInterval)) { context in
                // 盤面を表示領域いっぱいに最大化（縦横どちらの向きでも）。
                // 補助情報(日付/曜日/ひとこと)は ClockFaceContent 内で時刻の約1/4サイズで描画。
                ClockFaceContent(design: design, date: context.date)
                    .padding(12)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // 夜間減光オーバーレイ（盤面の上・コントロールの下に敷く。タップは透過）
            if nightMode {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            if showsControls {
                VStack {
                    HStack {
                        Button {
                            withAnimation { nightMode.toggle() }
                        } label: {
                            Image(systemName: nightMode ? "moon.fill" : "moon")
                                .font(.title)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding()
                        }
                        .accessibilityLabel(nightMode ? "夜間モードを解除" : "夜間モードにする")

                        Spacer()

                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.white.opacity(0.8))
                                .padding()
                        }
                        .accessibilityLabel("閉じる")
                    }
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .statusBarHidden(true)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation { showsControls.toggle() }
        }
        .onAppear { setIdleTimerDisabled(true) }
        .onDisappear { setIdleTimerDisabled(false) }
    }

    /// 画面を常時点灯に（時計表示中はスリープさせない）。UIKit が無い環境では何もしない。
    private func setIdleTimerDisabled(_ disabled: Bool) {
        #if canImport(UIKit)
        UIApplication.shared.isIdleTimerDisabled = disabled
        #endif
    }

    /// 背景は外側で敷くため、ここでは盤面のみ（背景なしで重ね描き）。
    @ViewBuilder
    private func faceContent(date: Date) -> some View {
        ZStack {
            switch design.style {
            case .analog:
                AnalogFaceView(design: design, date: date)
            case .dotMatrix:
                DotMatrixFaceView(design: design, date: date)
            case .digital:
                DigitalFaceView(design: design, date: date)
            }
            ComplicationOverlay(design: design, date: date)
        }
    }
}

/// 更新ティックを「実時刻の境界」に揃える TimelineSchedule。
///
/// `.periodic(from: Date(), ...)` はビュー表示時刻を基準にするため、分/秒の
/// 切り替わりが実際の :00 境界からズレる（最大で interval-ε 遅れる）。
/// 本スケジュールは参照時刻(2001-01-01 00:00:00、分・秒境界に一致)からの
/// 整数倍にティックを置くので、interval=60 なら毎分:00、interval=1 なら毎秒
/// ちょうどに更新される。
struct AlignedTimelineSchedule: TimelineSchedule {
    let interval: TimeInterval

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        let step = max(interval, 0.001)
        let t = startDate.timeIntervalSinceReferenceDate
        // startDate 以上で最初の境界
        var current = (t / step).rounded(.down) * step
        if current < t { current += step }

        return AnyIterator {
            let date = Date(timeIntervalSinceReferenceDate: current)
            current += step
            return date
        }
    }
}
