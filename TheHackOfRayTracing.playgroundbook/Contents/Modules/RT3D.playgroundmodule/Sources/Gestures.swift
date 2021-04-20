//
//  Gestures.swift
//  MTKRenderLoop
//
//  Created by 徐浩博 on 2021/4/4.
//

import Combine
import Foundation
import CoreGraphics

class Gestures {
    public static var mx: CGFloat = 0
    public static var my: CGFloat = 0
    public static var touched: Bool = false
    
    public static func SetTouch(_ moveX: CGFloat, _ moveY: CGFloat) {
        mx = moveX
        my = moveY
    }
    
    public static func ISTouched() -> Bool {
        return touched
    }
}
