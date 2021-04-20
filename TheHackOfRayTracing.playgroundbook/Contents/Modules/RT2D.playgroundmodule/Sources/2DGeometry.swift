//
//  2DGeometry.swift
//  2DRT
//
//  Created by 徐浩博 on 2020/4/13.
//  Copyright © 2021 徐浩博. All rights reserved.
//
import SpriteKit

public func clamp(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    if value <= min {
        return min
    } else if value >= min && value <= max {
        return value
    } else {
        return max
    }
}

public func roundToPlace(_ value: CGFloat, _ place: Int) -> CGFloat {
    let divisor = pow(10.0, CGFloat(place))
    return round(value * divisor) / divisor
}

public func positionXYToString(_ name: String, _ pos: CGPoint, _ place: Int) -> String {
    return "\(name)(\(roundToPlace(pos.x/10, place)),\(roundToPlace(pos.y/10, place)))"
}

public func line2DToString(_ name: String, _ line: Line2D) -> String {
    return "\(name): \(roundToPlace(line.a/10, 1))x + \(roundToPlace(line.b/10, 1))y + \(roundToPlace(line.c/10, 1))"
}

public func roundToPlace(_ value: Double, _ places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return round(value * divisor) / divisor
}

public func get2dDis(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return CGFloat(abs(sqrt(pow(dx, 2) + pow(dy, 2))))
}

public func isPointOnLineSegment(_ point: CGPoint, _ pointA: CGPoint, _ pointB: CGPoint) -> Bool {
    let lenab = get2dDis(from: pointA, to: pointB)
    let lenap = get2dDis(from: pointA, to: point)
    let lenpb = get2dDis(from: point, to: pointB)
    let exp: CGFloat = 0.1
    if  (lenap + lenpb - lenab) <= exp {
        return true
    }
    return false
}

public func atanRotation(len1: Float, len2: Float) -> Float {
    if len2 == 0 {
        return Float.pi / 2
    }else {
        if len1 == 0{
            return 0
        }else {
            return atan(len1 / len2)
        }
    }
}

public func linkTwoSpriteNode(from point1: CGPoint, to point2: CGPoint, with line: SKSpriteNode) {
    let dx = point1.x - point2.x
    let dy = point1.y - point2.y
    
    var rotate: Float = 0
    
    let center = CGPoint(x: (point1.x + point2.x) / 2, y: (point1.y + point2.y) / 2)
    line.position = CGPoint(x: center.x, y: center.y)
    
    line.size.height = get2dDis(from: point1, to: point2)
    
    if dx > 0 && dy > 0 {
        rotate = -atanRotation(len1: Float(dx), len2: Float(dy))
    }
    if dx < 0 && dy > 0 {
        rotate = atanRotation(len1: Float(-dx), len2: Float(dy))
    }
    if dx < 0 && dy < 0 {
        rotate = -atanRotation(len1: Float(-dx), len2: Float(-dy))
    }
    if dx > 0 && dy < 0 {
        rotate = atanRotation(len1: Float(dx), len2: Float(-dy))
    }
    if dy == 0 {
        rotate = Float.pi / 2
    }
    if dx == 0 {
        rotate = 0
    }
    
    line.zRotation = CGFloat(rotate)
}
