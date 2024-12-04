//
//  BoundaryHighlighterManager.swift
//  BoundaryHighlighter
//
//  Created by zcr on 2024/12/4.
//

import Cocoa
import CoreGraphics

class BoundaryHighlighterManager {
    static let shared = BoundaryHighlighterManager()
    private var hintWindows: [CGDirectDisplayID: NSWindow] = [:]

    func setup() {
        CGDisplayRegisterReconfigurationCallback(displayReconfigurationCallback, nil)
        setupDisplays()
    }
    
    private let displayReconfigurationCallback: CGDisplayReconfigurationCallBack = { (displayID, flags, userInfo) in
        print("reconfig callback", displayID, flags)
        BoundaryHighlighterManager.shared.setupForScreen(screenNumber: displayID)
    }
    
    private func createWindow(windowFrame: CGRect, displayBounds: CGRect, screen: NSScreen ) -> NSWindow {
        let convertedOrigin = CGPoint(x: windowFrame.origin.x - displayBounds.origin.x,
                                      y: displayBounds.origin.y + displayBounds.height - windowFrame.origin.y - windowFrame.height)
        let convertedFrame = CGRect(origin: convertedOrigin, size: windowFrame.size)
        print("addWindow windowFrame:\(windowFrame)")
        print("addWindow displayBounds:\(displayBounds)")
        print("addWindow convertedFrame:\(convertedFrame)")
        // Create the window with a borderless style
        let window = NSWindow(contentRect: convertedFrame,
                              styleMask: .borderless,
                              backing: .buffered,
                              defer: false,
                              screen: screen)
        window.isOpaque = false
        window.backgroundColor = NSColor.blue.withAlphaComponent(0.5)
        window.level = .screenSaver  // Ensure window is visible on top
        window.ignoresMouseEvents = true // So the window doesn't capture mouse events
        window.orderFront(nil)
        return window
    }

    // Setup the displays
    private func setupDisplays() {
        for (_, screen) in NSScreen.screens.enumerated() {
            let key = NSDeviceDescriptionKey("NSScreenNumber")
            guard let screenNumber = screen.deviceDescription[key] as? CGDirectDisplayID else {
                continue
            }
            print("screenNumber:\(screenNumber) frame:\(screen.frame)")
            setupForScreen(screenNumber: screenNumber)
        }
    }
    
    func getScreenForDisplayID(displayID: CGDirectDisplayID) -> NSScreen? {
        for screen in NSScreen.screens {
            if let screenID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
                if screenID.uint32Value == displayID {
                    return screen
                }
            }
        }
        return nil  // Return nil if no matching screen found
    }
    
    private func getDisplays() -> [CGDirectDisplayID] {
        var displayCount: UInt32 = 0
        let maxDisplays: UInt32 = 16
        var activeDisplays = [CGDirectDisplayID](repeating: 0, count: Int(maxDisplays))

        let error = CGGetActiveDisplayList(maxDisplays, &activeDisplays, &displayCount)
        guard error == .success else { return [] }

        let displays = activeDisplays.prefix(Int(displayCount))
        for displayID in displays {
            print("displayID:\(displayID) bounds:\(CGDisplayBounds(displayID))")
        }
        return Array(displays)
    }
    
    private func setupForScreen(screenNumber: CGDirectDisplayID) {
        guard let screen = getScreenForDisplayID(displayID: screenNumber) else {
            return
        }
        // remove added window
        if let window = hintWindows[screenNumber] {
            window.orderOut(nil)
            hintWindows.removeValue(forKey: screenNumber)
        }
        
        let displays = getDisplays()
        let screenRect = CGDisplayBounds(screenNumber)
        // find connected edge
        for displayID in displays {
            if displayID == screenNumber {
                continue
            }
            let displayRect = CGDisplayBounds(displayID)
            
            if screenRect.maxY == displayRect.minY && screenRect.minX < displayRect.maxX && screenRect.maxX > displayRect.minX {
                // rect2 is above rect1
                let startX = max(screenRect.minX, displayRect.minX)
                let endX = min(screenRect.maxX, displayRect.maxX)
                let windowFrame = CGRect(x: startX, y: screenRect.maxY - 10, width: endX - startX, height: 10)
                let window = createWindow(windowFrame: windowFrame, displayBounds: screenRect, screen: screen)
                hintWindows[screenNumber] = window
            }
            if screenRect.minY == displayRect.maxY && screenRect.minX < displayRect.maxX && screenRect.maxX > displayRect.minX {
                // rect2 is below rect1
                let startX = max(screenRect.minX, displayRect.minX)
                let endX = min(screenRect.maxX, displayRect.maxX)
                let windowFrame = CGRect(x: startX, y: screenRect.minY, width: endX - startX, height: 10)
                let window = createWindow(windowFrame: windowFrame, displayBounds: screenRect, screen: screen)
                hintWindows[screenNumber] = window
            }
            if screenRect.maxX == displayRect.minX && screenRect.minY < displayRect.maxY && screenRect.maxY > displayRect.minY {
                // rect2 is to the right of rect1
                let startY = max(screenRect.minY, displayRect.minY)
                let endY = min(screenRect.maxY, displayRect.maxY)
                let windowFrame = CGRect(x: screenRect.maxX - 10, y: startY, width: 10 , height: endY - startY)
                let window = createWindow(windowFrame: windowFrame, displayBounds: screenRect, screen: screen)
                hintWindows[screenNumber] = window
            }
            if screenRect.minX == displayRect.maxX && screenRect.minY < displayRect.maxY && screenRect.maxY > displayRect.minY {
                // rect2 is to the left of rect1
                let startY = max(screenRect.minY, displayRect.minY)
                let endY = min(screenRect.maxY, displayRect.maxY)
                let windowFrame = CGRect(x: screenRect.minX, y: startY, width: 10 , height: endY - startY)
                let window = createWindow(windowFrame: windowFrame, displayBounds: screenRect, screen: screen)
                hintWindows[screenNumber] = window
            }
        }
    }
}
