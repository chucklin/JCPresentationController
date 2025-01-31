//
//  SpotlightOverlay.swift
//  JCPresentationRemote
//
//  Created by chuck_lin on 2020/11/12.
//  Copyright © 2020 Chuck Lin. All rights reserved.
//

import Cocoa

class SpotlightOverlay: NSWindow {
    let mask = CAShapeLayer()
    let circleSize = CGFloat(200)
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

        alphaValue = 0.65
        backgroundColor = .clear
        
    }

    public func show() {
        let frame = NSScreen.main!.frame
        contentView?.layer?.backgroundColor = .black
        mask.frame = frame
        mask.fillRule = .evenOdd
        contentView?.layer?.mask = mask
        setFrame(NSScreen.main!.frame, display: false)

        // Push the hidden cursor to the top of stack
        // Then hide current cursor
        hiddenCursor.push()
        NSCursor.hide()
//        makeKeyAndOrderFront(self)
        orderFront(self)
        update(mouseLocation: mouseLocationOutsideOfEventStream)

        isShowed = true
    }

    public func hide() {
        NSCursor.unhide()
        hiddenCursor.pop()
        orderOut(self)

        isShowed = false
    }

    func update(mouseLocation location: NSPoint) {
//        NSLog("contentView?.layer?.mask \(contentView?.layer?.mask)")

        let path = NSBezierPath()
//        let path = NSBezierPath(rect: .infinite)
//        let path = NSBezierPath(rect: NSScreen.main!.frame)
//        path.close()
//        path.windingRule = .evenOdd
        let half = circleSize / 2
//        let circle = NSBezierPath(ovalIn: NSRect(origin: CGPoint(x: location.x - half, y: location.y - half), size: CGSize(width: circleSize, height: circleSize)))
//        path.append(circle)
        path.appendRect(NSScreen.main!.frame)
//        path.close()
//        path.appendArc(withCenter: location, radius: circleSize, startAngle: -CGFloat.pi, endAngle: CGFloat.pi, clockwise: true)
        let cursorLocation = CGPoint(
            x: location.x - half,
            y: location.y - half
        )
        path.appendOval(in: NSRect(origin: cursorLocation, size: CGSize(width: circleSize, height: circleSize)))
//        path.close()
//        path.fill()
//        path.close()
        mask.path = path.quartzPath
//        mask.path = NSBezierPath(rect: NSRect(origin: CGPoint(x: location.x - half, y: location.y - half), size: CGSize(width: circleSize, height: circleSize))).quartzPath

//        CATransaction.begin()
//        CATransaction.setDisableActions(true)
//        circle.frame = NSRect(origin: CGPoint(x: location.x - half, y: location.y - half), size: CGSize(width: circleSize, height: circleSize))
//        CATransaction.commit()

//        NSLog("contentView.layer \(contentView?.layer?.mask)")
    }
}

extension NSBezierPath {
    var quartzPath: CGPath {
        get {
            let path = CGMutablePath()
            var points = [NSPoint](repeating: .zero, count: 3)
            var didClosePath = false
            for i in 0..<elementCount {
                let type = element(at: i, associatedPoints: &points)
                switch type {

                case .moveTo:
                    path.move(to: points[0])
                case .lineTo:
                    path.addLine(to: points[0])
                    didClosePath = false
                case .curveTo:
                    path.addCurve(to: points[2], control1: points[0], control2: points[1])
                    didClosePath = false
                case .closePath:
                    path.closeSubpath()
                    didClosePath = true
                @unknown default:
                    break
                }

            }

            if !didClosePath {
                path.closeSubpath()
            }
            return path
        }
    }
}
