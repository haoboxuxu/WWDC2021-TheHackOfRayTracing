//
//  Utilitys.swift
//  RTSwift
//
//  Created by 徐浩博 on 2021/2/6.
//

import Foundation
import simd

public let infinity: Float = Float.infinity
public let pi: Float = 3.14

public func randomFloat() -> Float {
    return Float(drand48())
}

public func randomFloat(_ min: Float, _ max: Float) -> Float {
    return Float.random(in: min...max)
}

public func clamp(_ x: Float, _ min: Float, _ max: Float) -> Float {
    if x < min {
        return min
    }
    if x > max {
        return max
    }
    return x
}

public func degrees2radians(degrees: Float) -> Float {
    return degrees * pi / 180.0
}

// MARK: extension for vector3
public func dot(_ left: Vector3, _ right: Vector3) -> Float {
    return simd_dot(left.elm, right.elm)
}

public func cross(_ left: Vector3, _ right: Vector3) -> Vector3 {
    return Vector3(simd_cross(left.elm, right.elm))
}
