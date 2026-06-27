//
//  ClockWidget.swift
//  ClockWidget
//

import WidgetKit
import SwiftUI

struct ClockEntry: TimelineEntry {
    let date: Date
    let design: ClockFaceDesign
}

struct ClockProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockEntry {
        ClockEntry(date: .now, design: .default)
    }

    func getSnapshot(in context: Context, completion: @escaping (ClockEntry) -> Void) {
        completion(ClockEntry(date: .now, design: ClockFaceStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockEntry>) -> Void) {
        let design = ClockFaceStore.load()
        let calendar = Calendar.current
        let now = Date.now

        // 現在時刻を分境界（00秒）に丸める
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let startMinute = calendar.date(from: components) ?? now

        var entries: [ClockEntry] = []
        for offset in 0..<60 {
            if let entryDate = calendar.date(byAdding: .minute, value: offset, to: startMinute) {
                entries.append(ClockEntry(date: entryDate, design: design))
            }
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

struct ClockWidgetEntryView: View {
    var entry: ClockProvider.Entry

    var body: some View {
        ClockFaceView(design: entry.design, date: entry.date)
    }
}

struct ClockWidget: Widget {
    let kind = "ClockWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockProvider()) { entry in
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

#Preview(as: .systemSmall) {
    ClockWidget()
} timeline: {
    ClockEntry(date: .now, design: .default)
}
