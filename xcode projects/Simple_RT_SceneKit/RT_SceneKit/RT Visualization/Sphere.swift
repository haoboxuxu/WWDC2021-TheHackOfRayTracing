//
//  Sphere.swift
//  RTSwift
//
//  Created by 徐浩博 on 2021/2/7.
//

import Foundation

public class Sphere {
    
    public var center: Point3
    public var radius: Float
    public var material: Material?
    
    public init(center: Point3, radius: Float) {
        self.center = center
        self.radius = radius
    }
    
    init(center: Point3, radius: Float, material: Material) {
        self.center = center
        self.radius = radius
        self.material = material
    }
    
    public func intersect(ray: Ray, tMin: Float, tMax: Float, record: inout HitRecord) -> Bool {
        
        let oc = ray.origin - center
        let a = ray.direction.lengthSquared
        let half_b = dot(oc, ray.direction)
        let c = oc.lengthSquared - radius * radius
        
        let discriminant = half_b * half_b - a * c
        if discriminant < 0 {
            return false
        }
        let sqrtd = sqrt(discriminant)
        
        // Find the nearest root that lies in the acceptable range.
        var root = (-half_b - sqrtd) / a
        if (root < tMin || tMax < root) {
            root = (-half_b + sqrtd) / a
            if (root < tMin || tMax < root) {
                return false
            }
        }
        
        record.t = root
        record.point = ray.at(record.t)
        record.normal = (record.point - center) / radius
        
        let outward_normal = (record.point - center) / radius;
        record.setFaceNormal(ray: ray, outwardNormal: outward_normal)
        record.material = material
        
        return true
    }
}
