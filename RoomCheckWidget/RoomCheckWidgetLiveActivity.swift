//
//  RoomCheckWidgetLiveActivity.swift
//  RoomCheckWidget
//
//  Created by John Re on 6/10/2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RoomCheckWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct RoomCheckWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RoomCheckWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension RoomCheckWidgetAttributes {
    fileprivate static var preview: RoomCheckWidgetAttributes {
        RoomCheckWidgetAttributes(name: "World")
    }
}

extension RoomCheckWidgetAttributes.ContentState {
    fileprivate static var smiley: RoomCheckWidgetAttributes.ContentState {
        RoomCheckWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: RoomCheckWidgetAttributes.ContentState {
         RoomCheckWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: RoomCheckWidgetAttributes.preview) {
   RoomCheckWidgetLiveActivity()
} contentStates: {
    RoomCheckWidgetAttributes.ContentState.smiley
    RoomCheckWidgetAttributes.ContentState.starEyes
}
