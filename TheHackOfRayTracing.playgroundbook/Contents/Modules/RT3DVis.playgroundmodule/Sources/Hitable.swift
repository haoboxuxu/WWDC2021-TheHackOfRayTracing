//
//  Hitable.swift
//  RTSwift
//
//  Created by 徐浩博 on 2021/2/7.
//

import Foundation

public class HitRecord {
    public var point: Point3
    public var normal: Vector3
    public var material: Material?
    public var t: Float
    public var frontFace: Bool
    
    public func setFaceNormal(ray: Ray, outwardNormal: Vector3) {
        frontFace = dot(ray.direction, outwardNormal) < 0;
        normal = frontFace ? outwardNormal : -outwardNormal
    }
    
    public init() {
        t = 0
        point = Point3(0, 0, 0)
        normal = Vector3(0, 0, 0)
        frontFace = true
    }
}
