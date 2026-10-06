//
//  RoomCheckWidget.swift
//  RoomCheckWidget
//
//  Created by John Re on 6/10/2026.
//

import WidgetKit
import SwiftUI

struct RoomEntry: TimelineEntry {
    let date: Date
    let summary: String
}

struct RoomProvider: TimelineProvider {
    func placeholder(in context: Context) -> RoomEntry {
        RoomEntry(date: Date(), summary: "No rooms")
    }

    func getSnapshot(in context: Context, completion: @escaping (RoomEntry) -> Void) {
        completion(RoomEntry(date: Date(), summary: current()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RoomEntry>) -> Void) {
        let entry = RoomEntry(date: Date(), summary: current())
        completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(900))))
    }

    private func current() -> String {
        let store = UserDefaults(suiteName: "group.JohnReUTS.RoomCheck")
        let summary = store?.string(forKey: "widgetSummary") ?? ""
        return summary.isEmpty ? "No rooms" : summary
    }
}

struct RoomCheckWidgetView: View {
    var entry: RoomEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("RoomCheck")
                Text(entry.summary)
            }
        default:
            VStack(alignment: .leading, spacing: 8) {
                Text("RoomCheck")
                    .font(.headline)
                Text(entry.summary)
                    .font(.title3)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding()
        }
    }
}

struct RoomCheckWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "RoomCheckWidget", provider: RoomProvider()) { entry in
            RoomCheckWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("RoomCheck")
        .description("Unchecked rooms for the open inspection.")
        .supportedFamilies([.accessoryRectangular, .systemMedium])
    }
}

