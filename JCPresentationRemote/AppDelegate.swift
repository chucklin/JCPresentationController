//
//  AppDelegate.swift
//  JCPresentationRemote
//
//  Created by chuck_lin on 2020/11/12.
//  Copyright © 2020 Chuck Lin. All rights reserved.
//

import Cocoa
import JoyConSwift

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let joyConManager = JoyConManager()
    let spotlightWindow = SpotlightOverlay()
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        initJoyConManager()
        initStatusItem()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func initJoyConManager() {
        // Set connection event callbacks
        joyConManager.connectHandler = { controller in
            // Do something with the controller
            controller.setPlayerLights(l1: .off, l2: .on, l3: .off, l4: .off)
            controller.enableIMU(enable: true)
            controller.setInputMode(mode: .standardFull)
            controller.buttonPressHandler = { button in
                if button == .ZR {
                    print("press ZR button")
                    DispatchQueue.main.async {
                        NSApp.activate(ignoringOtherApps: true)
                        self.spotlightWindow.show()
                    }
                } else if button == .B {
                    print("press B")
                }
            }
            controller.buttonReleaseHandler = { button in
                if button == .ZR {
                    DispatchQueue.main.async {
                        NSApp.deactivate()
                        self.spotlightWindow.hide()
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
    }

}
