//
//  Lambertian.swift
//  RTSwift
//
//  Created by 徐浩博 on 2021/2/8.
//

import Foundation

public protocol Material {
    func scatter(ray: Ray, record: HitRecord, attenuation: inout Vector3, scattered: inout Ray) -> Bool
}

public class BasicMaterial: Material {
    
    public var albedo: Color
    
    public init(albedo: Color) {
        self.albedo = albedo
    }
    
    public func scatter(ray: Ray, record: HitRecord, attenuation: inout Vector3, scattered: inout Ray) -> Bool {
        attenuation = albedo
        return true
    }
}
