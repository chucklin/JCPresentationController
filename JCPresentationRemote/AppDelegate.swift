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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application

        // Set connection event callbacks
        joyConManager.connectHandler = { controller in
            // Do something with the controller
            controller.setPlayerLights(l1: .off, l2: .on, l3: .off, l4: .off)
            controller.enableIMU(enable: true)
            controller.setInputMode(mode: .standardFull)
            controller.buttonPressHandler = { button in
                if button == .A {
                    print("hi")
                }
            }
        }
        joyConManager.disconnectHandler = { controller in
            // Clean the controller data
        }

        // Start waiting for the connection events
        joyConManager.runAsync()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

