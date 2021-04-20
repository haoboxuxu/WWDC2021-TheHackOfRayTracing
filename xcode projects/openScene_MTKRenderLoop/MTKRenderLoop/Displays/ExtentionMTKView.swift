//
//  MTKMainView.swift
//  MTKRenderLoop
//
//  Created by 徐浩博 on 2021/4/1.
//

import MetalKit

extension MTKView {
    open override func touchesBegan(with event: NSEvent) {
        Gestures.touched = true
    }
    
    open override func touchesMoved(with event: NSEvent) {
        Gestures.SetTouch(event.deltaX, event.deltaY)
    }
    
    open override func touchesEnded(with event: NSEvent) {
        Gestures.touched = false
    }
}

//key input
extension MTKView {
    open override var acceptsFirstResponder: Bool {
        return true
    }
    
    open override func keyDown(with event: NSEvent) {
        Keyboard.SetKeyPress(event.keyCode, isOn: true)
    }
    
    open override func keyUp(with event: NSEvent) {
        Keyboard.SetKeyPress(event.keyCode, isOn: false)
    }
}

//mouse intput
extension MTKView {
    open override func mouseDown(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }
    
    open override func mouseUp(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
    open override func rightMouseDown(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }
    
    open override func rightMouseUp(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
    
    open override func otherMouseDown(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: true)
    }
    
    open override func otherMouseUp(with event: NSEvent) {
        Mouse.SetMouseButtonPressed(button: event.buttonNumber, isOn: false)
    }
}

//mouse move
extension MTKView {
    open override func mouseMoved(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    open override func scrollWheel(with event: NSEvent) {
        Mouse.ScrollMouse(deltaY: Float(event.deltaY))
    }
    
    open override func mouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    open override func rightMouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    open override func otherMouseDragged(with event: NSEvent) {
        setMousePositionChanged(event: event)
    }
    
    private func setMousePositionChanged(event: NSEvent) {
        let overallLocation = float2(Float(event.locationInWindow.x), Float(event.locationInWindow.y))
        let deltaChange = float2(Float(event.deltaX), Float(event.deltaY))
        Mouse.SetMousePositionChange(overallPosition: overallLocation, deltaPosition: deltaChange)
    }
    
    open override func updateTrackingAreas() {
        let area = NSTrackingArea(rect: self.bounds,
                                  options: [NSTrackingArea.Options.activeAlways,
                                            NSTrackingArea.Options.mouseMoved,
                                            NSTrackingArea.Options.enabledDuringMouseDrag],
                                  owner: self,
                                  userInfo: nil)
        self.addTrackingArea(area)
    }
}
