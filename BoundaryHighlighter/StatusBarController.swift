//
//  StatusBarController.swift
//  BoundaryHighlighter
//
//  Created by zcr on 2024/12/4.
//

import AppKit

class StatusBarController: NSObject {

    // Declare the status item
    private var statusItem: NSStatusItem?
    
    func createStatusBarItem() {
        // Create a new status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set the image for the status item
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "star", accessibilityDescription: "Star Icon")
        }
        
        // Add a menu to the status item
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: toggleMenuItemTitle(isEnabled: true), action: #selector(toggle), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        for item in menu.items {
            item.target = self
        }
        
        statusItem?.menu = menu
    }
    
    func toggleMenuItemTitle(isEnabled: Bool) -> String {
        return isEnabled ? "Disable" : "Enable"
    }
    
    @objc func toggle(_ sender: NSMenuItem) {
        var isEnabled = BoundaryHighlighterManager.shared.isEnabled
        
        isEnabled.toggle()
        sender.title = toggleMenuItemTitle(isEnabled: isEnabled)
        
        if isEnabled {
            BoundaryHighlighterManager.shared.enable()
        } else {
            BoundaryHighlighterManager.shared.disable()
        }
    }
    
    @objc func quitApp() {
        // Quit the app when the quit menu item is selected
        NSApplication.shared.terminate(nil)
    }
}
