//
//  HitableList.swift
//  RTSwift
//
//  Created by 徐浩博 on 2021/2/7.
//

import Foundation

public class RTScene {
    public var objects: [Sphere] = []
    
    public func intersect(ray: Ray, tMin: Float, tMax: Float, record: inout HitRecord) -> Bool {
        var tempRecord = HitRecord()
        var hitAnything: Bool = false
        var closestSoFar = tMax
        
        for object in objects {
            if object.intersect(ray: ray, tMin: tMin, tMax: closestSoFar, record: &tempRecord) {
                hitAnything = true
                closestSoFar = tempRecord.t
                record = tempRecord
            }
        }
        
        return hitAnything;
    }
    
}
