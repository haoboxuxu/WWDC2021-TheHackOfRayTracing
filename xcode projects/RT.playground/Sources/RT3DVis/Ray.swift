//
//  Ray.swift
//  RTSwift
//
//  Created by 徐浩博 on 2021/2/7.
//

import Foundation

public class Ray {
    private var rayDirection: Vector3!
    private var rayOrigin: Point3!
    
    public init() {
        
    }
    
    public init(origin: Point3, direction: Vector3) {
        self.rayOrigin = origin
        self.rayDirection = direction
    }
    
    public var direction: Vector3 { self.rayDirection }
    public var origin: Point3 { self.rayOrigin }
    
    public func at(_ t: Float) -> Point3 {
        rayOrigin + t * rayDirection
    }
}
