//
//  BoundaryHighlighterApp.swift
//  BoundaryHighlighter
//
//  Created by zcr on 2024/12/4.
//

import SwiftUI

@main
struct BoundaryHighlighterApp: App {
    init() {
        BoundaryHighlighterManager.shared.setup()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
