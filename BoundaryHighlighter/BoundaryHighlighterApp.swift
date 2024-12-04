//
//  BoundaryHighlighterApp.swift
//  BoundaryHighlighter
//
//  Created by zcr on 2024/12/4.
//

import SwiftUI

@main
struct BoundaryHighlighterApp: App {
    private var statusBarController = StatusBarController()
    
    init() {
        BoundaryHighlighterManager.shared.enable()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    statusBarController.createStatusBarItem()
                }
        }
    }
}
