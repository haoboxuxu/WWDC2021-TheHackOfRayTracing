//
//  Camera.swift
//  RTSwift
//
//  Created by 徐浩博 on 2021/2/7.
//

import Foundation

public class Camera {
    
    public var origin: Point3
    public var lower_left_corner: Point3
    public var horizontal: Vector3
    public var vertical: Vector3
    
    public init() {
        let aspect_ratio: Float = 4.0 / 3.0
        let viewport_height: Float = 2.0
        let viewport_width: Float = aspect_ratio * viewport_height
        let focal_length: Float = 1.3
        
        origin = Vector3(0, 0, 0)
        horizontal = Vector3(viewport_width, 0.0, 0.0)
        vertical = Vector3(0.0, viewport_height, 0.0)
        lower_left_corner = origin - horizontal/2 - vertical/2 - Vector3(0, 0, focal_length)
    }
    
    func getRay(u: Float, v: Float) -> Ray {
        return Ray(origin: origin,
                   direction: lower_left_corner + u * horizontal + v * vertical - origin)
    }
}
