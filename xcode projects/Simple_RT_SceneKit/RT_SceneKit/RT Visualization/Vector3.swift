//
//  Vector3.swift
//  RTSwift
//
//  Created by 徐浩博 on 2021/2/6.
//

import Foundation
import simd

public struct Vector3 {
    // MARK: model
    public var e: simd_float3
    
    // MARK: initializer
    init() {
        self.e = simd_float3(0.0, 0.0, 0.0)
    }
    
    init(_ x: Float, _ y: Float, _ z: Float) {
        self.e = simd_float3(x: x, y: y, z: z)
    }
    
    init(_ simdfloat3: simd_float3) {
        self.e = simdfloat3
    }
    
    // MARK: properties
    // reasonable for vector3 or point3
    var x: Float { e.x }
    var y: Float { e.y }
    var z: Float { e.z }
    
    // reasonable for color3
    var r: Float { e.x }
    var g: Float { e.y }
    var b: Float { e.z }
    
    var elm: simd_float3 { e }
    
    var lengthSquared: Float { simd_length_squared(self.e) }
    
    var length: Float { simd_length(self.e) }
    
    // MARK: custom operators
    static prefix func - (vec3: Vector3) -> Vector3 {
        Vector3(-vec3.x, -vec3.y, -vec3.z)
    }
    
    // vector3 vector3 operations
    static func + (left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func - (left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func * (left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.x * right.x, left.y * right.y, left.z * right.z)
    }
    
    static func / (left: Vector3, right: Vector3) -> Vector3 {
        Vector3(left.x / right.x, left.y / right.y, left.z / right.z)
    }
    
    // vector3 float operations
    static func + (left: Vector3, t: Float) -> Vector3 {
        Vector3(left.x + t, left.y + t, left.z + t)
    }
    
    static func - (left: Vector3, t: Float) -> Vector3 {
        Vector3(left.x - t, left.y - t, left.z - t)
    }
    
    static func * (left: Vector3, t: Float) -> Vector3 {
        Vector3(left.x * t, left.y * t, left.z * t)
    }
    
    static func / (left: Vector3, t: Float) -> Vector3 {
        Vector3(left.x / t, left.y / t, left.z / t)
    }
    
    // float vector3 operations
    static func + (t: Float, right: Vector3) -> Vector3 {
        Vector3(t + right.x, t + right.y, t + right.z)
    }
    
    static func - (t: Float, right: Vector3) -> Vector3 {
        Vector3(t - right.x, t - right.y, t - right.z)
    }
    
    static func * (t: Float, right: Vector3) -> Vector3 {
        Vector3(t * right.x, t * right.y, t * right.z)
    }
    
    static func / (t: Float, right: Vector3) -> Vector3 {
        Vector3(t / right.x, t / right.y, t / right.z)
    }
    
    // vector3 self operations
    static func += (left: inout Vector3, right: Vector3) {
        left = left + right
    }
    
    static func -= (left: inout Vector3, right: Vector3) {
        left = left - right
    }
    
    static func *= (left: inout Vector3, right: Vector3) {
        left = left * right
    }
    
    static func /= (left: inout Vector3, right: Vector3) {
        left = left / right
    }
    
    static func *= (left: inout Vector3, right: Float) {
        left = left * right
    }
    
    static func /= (left: inout Vector3, right: Float) {
        left = left / right
    }
    
    // MARK: 3d math
    static func random() -> Vector3 {
        Vector3(randomFloat(), randomFloat(), randomFloat())
    }
    
    static func random(_ min: Float, _ max: Float) -> Vector3 {
        Vector3(randomFloat(min, max), randomFloat(min, min), randomFloat(min, max))
    }
    
    
    // mutating
    mutating func normalize() -> Vector3 {
        let k = 1.0 / length
        e[0] *= k
        e[1] *= k
        e[2] *= k
        return self
    }
    
    func toUnitVector() -> Vector3 {
        self / length
    }
    
    // TODO
    static func randomInUnitSphere() -> Vector3 {
//        while true {
//            let v3 = random(-1, 1)
//            if (v3.lengthSquared < 1) {
//                return v3
//            }
//        }
        var p: Vector3
        repeat {
            p = 2.0 * Vector3(randomFloat(), randomFloat(), randomFloat()) - Vector3(1.0, 1.0, 1.0)
        } while p.lengthSquared >= 1.0
        
        return p
    }
    
    static func randomUnitVector() -> Vector3 {
        return self.randomInUnitSphere().toUnitVector()
    }
    
    static func randomInHemiSphere(normal: Vector3) -> Vector3 {
        let inUnitSphereV3 = randomInUnitSphere()
        if dot(inUnitSphereV3, normal) > 0.0 {
            return inUnitSphereV3
        } else {
            return -inUnitSphereV3
        }
    }
    
    static func reflect(v: Vector3, n: Vector3) -> Vector3 {
        return v - 2 * dot(v, n) * n;
    }

    static func refract(uv: Vector3, n: Vector3, etai_over_etat: Float) -> Vector3 {
        let cos_theta = min(dot(-uv, n), 1.0)
        let r_out_perp =  etai_over_etat * (uv + cos_theta*n)
        let r_out_parallel = -sqrt(abs(1.0 - r_out_perp.lengthSquared)) * n
        return r_out_perp + r_out_parallel
    }

    static func randomInUnitDisk() -> Vector3 {
        while true {
            let p = Vector3(randomFloat(-1, 1), randomFloat(-1, 1), 0);
            if p.lengthSquared >= 1 {
                continue
            }
            return p;
        }
    }
    
    func isNearZero() -> Bool {
        let s: Float = 1e-8
        return (abs(e[0]) < s) && (abs(e[1]) < s) && (abs(e[2]) < s);
    }
}

public typealias Point3 = Vector3
public typealias Color = Vector3
