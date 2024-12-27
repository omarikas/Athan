//
//  AthanWidgetLiveActivity.swift
//  AthanWidget
//
//  Created by Omarrhazem Khattab  on 23/12/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AthanWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AthanWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AthanWidgetAttributes.self) { context in
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

extension AthanWidgetAttributes {
    fileprivate static var preview: AthanWidgetAttributes {
        AthanWidgetAttributes(name: "World")
    }
}

extension AthanWidgetAttributes.ContentState {
    fileprivate static var smiley: AthanWidgetAttributes.ContentState {
        AthanWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AthanWidgetAttributes.ContentState {
         AthanWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AthanWidgetAttributes.preview) {
   AthanWidgetLiveActivity()
} contentStates: {
    AthanWidgetAttributes.ContentState.smiley
    AthanWidgetAttributes.ContentState.starEyes
}
