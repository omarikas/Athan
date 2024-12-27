//
//  AthanWidgetBundle.swift
//  AthanWidget
//
//  Created by Omarrhazem Khattab  on 23/12/2024.
//

import WidgetKit
import SwiftUI

@main
struct AthanWidgetBundle: WidgetBundle {
    var body: some Widget {
        AthanWidget()
        AthanWidgetControl()
        AthanWidgetLiveActivity()
    }
}
