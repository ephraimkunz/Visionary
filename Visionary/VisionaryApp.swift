//
//  VisionaryApp.swift
//  Visionary
//
//  Created by Ephraim Kunz on 9/11/24.
//

import SwiftUI

@main
struct VisionaryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(PhotoModel())
    }
}
