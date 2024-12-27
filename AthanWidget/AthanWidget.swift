//
//  AthanWidget.swift
//  AthanWidget
//
//  Created by Omarrhazem Khattab  on 23/12/2024.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct AthanWidgetEntryView : View {
    var entry: Provider.Entry
    

    var body: some View {
        ZStack{
            Image("athanpic")
                .resizable() // Make the image resizable
                .frame(width: 350)
            HStack { if let sharedDefaults = UserDefaults(suiteName: "group.omarika.atthan") {
                
                if let fajr = sharedDefaults.string(forKey: "fajr"){
                    
                    VStack{
                        Text("fajr")
                        Text("\(fajr)")
                        
                    }
                    
                }
                if let fajr = sharedDefaults.string(forKey: "dhuhr"){
                    
                    VStack{
                        Text("dhuhr")
                        Text("\(fajr)")
                        
                    }
                    
                }
                if let fajr = sharedDefaults.string(forKey: "asr"){
                    
                    VStack{
                        Text("asr")
                        Text("\(fajr)")
                        
                    }
                    
                }
                if let fajr = sharedDefaults.string(forKey: "maghrib"){
                    
                    VStack{
                        Text("maghrib")
                        Text("\(fajr)")
                        
                    }
                    
                }
                if let fajr = sharedDefaults.string(forKey: "isha"){
                    
                    VStack{
                        Text("isha")
                        Text("\(fajr)")
                        
                    }
                    
                }
                
                
                
            }
                
                
                
                
            }.padding(10)
        }
    }
    }


struct AthanWidget: Widget {
    let kind: String = "AthanWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            AthanWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    AthanWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
