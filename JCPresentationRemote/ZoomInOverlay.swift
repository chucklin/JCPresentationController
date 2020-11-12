//
//  ZoomInOverlay.swift
//  JCPresentationRemote
//
//  Created by chuck_lin on 2020/11/12.
//  Copyright © 2020 Chuck Lin. All rights reserved.
//

import Cocoa

class ZoomInOverlay: NSWindow {
    let scaledImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 400, height: 400))
    let mask = CAShapeLayer()
    let circleSize = CGFloat(400)
    var capturedScreen: CGImage?
    var hiddenCursor = NSCursor.init(image: NSImage.init(size: NSSize(width: 1, height: 1)), hotSpot: NSPoint(x: 0, y: 0))
    
    var isShowed = false

    init() {
        super.init(
            contentRect: NSMakeRect(
                0, 0, NSScreen.main!.frame.width, NSScreen.main!.frame.height
            ),
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        hasShadow = false
        level = .statusBar
        acceptsMouseMovedEvents = true
        hidesOnDeactivate = true

        alphaValue = 1
//        backgroundColor = NSColor(calibratedWhite: 0, alpha: 0.65)
        backgroundColor = .clear

        contentView?.addSubview(scaledImageView)
    }

    public func show() {
        scaledImageView.layer?.borderWidth = 1
        scaledImageView.layer?.borderColor = .white
        scaledImageView.layer?.cornerRadius = circleSize / 2

        let displayID = CGMainDisplayID()
        capturedScreen = CGDisplayCreateImage(displayID, rect: NSScreen.main!.frame)

        hiddenCursor.push()
        NSCursor.hide()

        orderFront(self)
        update(mouseLocation: mouseLocationOutsideOfEventStream)

        isShowed = true
    }

    public func hide() {
        NSCursor.unhide()
        hiddenCursor.pop()
        orderOut(self)
        capturedScreen = nil

        isShowed = false
    }
    
    func update(mouseLocation location: NSPoint) {
        let half = circleSize / 2

        let cursorLocation = CGPoint(
            x: location.x - half,
            y: location.y - half
        )

        scaledImageView.frame = NSRect(origin: cursorLocation, size: CGSize(width: circleSize, height: circleSize))

        let scale = CGFloat(2.0) // hack for retina display, should be a calculated value
        let point = CGPoint(
            x: location.x * scale - half/scale,
            y: NSScreen.main!.frame.maxY * scale - location.y * scale - half/scale
        )
        let captureRect = CGRect(
            origin: point,
            size: CGSize(width: half, height: half)
        )

        let readyToScale = capturedScreen!.cropping(to: captureRect)!
        let img = NSImage(cgImage: readyToScale, size: scaledImageView.bounds.size)
        img.size = NSSize(width: circleSize, height: circleSize)

        scaledImageView.image = img
    }
}

