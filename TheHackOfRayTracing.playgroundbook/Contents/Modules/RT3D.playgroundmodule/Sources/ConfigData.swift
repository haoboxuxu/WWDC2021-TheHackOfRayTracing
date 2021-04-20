//
//  HostData.swift
//  MTKRenderLoop
//
//  Created by 徐浩博 on 2021/3/31.
//

import simd

public typealias float2 = SIMD2<Float>
public typealias float3 = SIMD3<Float>
public typealias float4 = SIMD4<Float>

protocol sizeable { }

extension sizeable {
    static var size: Int {
        return MemoryLayout<Self>.size
    }
    
    static var stride: Int {
        return MemoryLayout<Self>.stride
    }
    
    static func size(_ count: Int) -> Int {
        return MemoryLayout<Self>.size * count
    }
    
    static func stride(_ count: Int) -> Int {
        return MemoryLayout<Self>.stride * count
    }
}

extension UInt32: sizeable { }
extension Int32: sizeable { }
extension Float: sizeable { }
extension float2: sizeable { }
extension float3: sizeable { }
extension float4: sizeable { }

public struct RenderConfig {
    // Image Config
    var imageWidth: Float
    var imageHeight: Float
    var aspectRatio: Float
    // Game Time
    var gameTime: Float
    // Render Config
    var samplesPerPixel: Float
    var maxDepth: Float
    // tick time => to generate random seed in metal
    var tickSeed: Float
    // Camera Config
    var viewportHeight: Float
    var viewportWidth: Float
    var focalLength: Float
    var vfov: Float
    var origin: float3
    var horizontal: float3
    var vertical: float3
    var lowerLeftCorner: float3
    var lookfrom: float3
    var lookat: float3
    var vup: float3
    // free sphere
    var spherePos: float3
}
