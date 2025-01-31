//
//  AppDelegate.swift
//  JCPresentationRemote
//
//  Created by chuck_lin on 2020/11/12.
//  Copyright © 2020 Chuck Lin. All rights reserved.
//

import Cocoa
import JoyConSwift
import InputMethodKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let joyConManager = JoyConManager()
    let spotlightWindow = SpotlightOverlay()
    let zoomInWindow = ZoomInOverlay()
    var statusItem: NSStatusItem?

    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var firstMenuItem: NSMenuItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        initJoyConManager()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    override func awakeFromNib() {
        initStatusItem()
    }

    func initJoyConManager() {
        // Set connection event callbacks
        joyConManager.connectHandler = { controller in
            // Do something with the controller
            controller.setPlayerLights(l1: .off, l2: .on, l3: .off, l4: .off)
            controller.enableIMU(enable: true)
            controller.setInputMode(mode: .standardFull)
            controller.rightStickPosHandler = { pos in
                DispatchQueue.main.async {
                    self.stickMouseHandler(pos: pos, speed: CGFloat(20.0))
                }
            }
            controller.buttonPressHandler = { button in
                if button == .ZR {
//                    print("Activate spotlight window")
                    DispatchQueue.main.async {
                        NSApp.activate(ignoringOtherApps: true)
                        self.spotlightWindow.show()
                    }
                } else if button == .R {
                    DispatchQueue.main.async {
                        NSApp.activate(ignoringOtherApps: true)
                        self.zoomInWindow.show()
                    }
                } else if button == .A {
//                    print("Simulate keyboard right click")
                    DispatchQueue.main.async {
                        let keyboardDown = CGEvent(
                            keyboardEventSource: nil,
                            virtualKey: UInt16(kVK_RightArrow),
                            keyDown: true
                        )
                        keyboardDown?.post(tap: .cghidEventTap)
                        let keyboardUp = CGEvent(
                            keyboardEventSource: nil,
                            virtualKey: UInt16(kVK_RightArrow),
                            keyDown: false
                        )
                        keyboardUp?.post(tap: .cghidEventTap)
                    }
                } else if button == .Y {
//                    print("Simulate keyboard left click")
                    DispatchQueue.main.async {
                        let keyboardDown = CGEvent(
                            keyboardEventSource: nil,
                            virtualKey: UInt16(kVK_LeftArrow),
                            keyDown: true
                        )
                        keyboardDown?.post(tap: .cghidEventTap)
                        let keyboardUp = CGEvent(
                            keyboardEventSource: nil,
                            virtualKey: UInt16(kVK_LeftArrow),
                            keyDown: false
                        )
                        keyboardUp?.post(tap: .cghidEventTap)
                    }
                }
            }
            controller.buttonReleaseHandler = { button in
                if button == .ZR {
//                    print("Deactivate spotlight window")
                    DispatchQueue.main.async {
                        self.spotlightWindow.hide()
                        NSApp.hide(nil)
                    }
                } else if button == .R {
                    DispatchQueue.main.async {
                        self.zoomInWindow.hide()
                        NSApp.hide(nil)
                    }
                }
            }
        }
        joyConManager.disconnectHandler = { controller in
            // Clean the controller data
        }

        // Start waiting for the connection events
        joyConManager.runAsync()
    }

    func initStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "JPR"

        if let menu = menu {
            statusItem?.menu = menu
        }

    }

    func stickMouseHandler(pos: CGPoint, speed: CGFloat) {
        if pos.x == 0 && pos.y == 0 {
            return
        }
        let mousePos = NSEvent.mouseLocation
        let newX = mousePos.x + pos.x * speed
        let newY = NSScreen.main!.frame.maxY - mousePos.y - pos.y * speed
        let newPos = CGPoint(x: newX, y: newY)
        CGDisplayMoveCursorToPoint(CGMainDisplayID(), newPos)

        let newPosUpdate = NSPoint(
            x: newX,
            y: mousePos.y + pos.y * speed
        )

        if self.spotlightWindow.isShowed {
            self.spotlightWindow.update(mouseLocation: newPosUpdate)
        }

        if self.zoomInWindow.isShowed {
            self.zoomInWindow.update(mouseLocation: newPosUpdate)
        }
    }

}
