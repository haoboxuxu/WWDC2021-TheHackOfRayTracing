//
//  StaticRenderConfig.swift
//  MTKRenderLoop
//
//  Created by 徐浩博 on 2021/4/1.
//

import Foundation

public var _imageWidth: Float = 800 // mac is Retina, need *2 to fillout the screen(or move it to shader)
public var _imageHeight: Float = 1000
public var _samplesPerPixel: Float = 15
public var _maxDepth: Float = 10
public let _aspectRatio: Float = _imageWidth / _imageHeight

public let _viewportHeight: Float = 2.0
public let _viewportWidth: Float = _aspectRatio * _viewportHeight
public let _focalLength: Float = 1.0
public let _origin: float3 = float3(0, 0, 0)
public let _horizontal: float3 = float3(_viewportWidth, 0, 0)
public let _vertical: float3 = float3(0, _viewportHeight, 0)
public let _lowerLeftCorner: float3 = _origin - _horizontal/2 - _vertical/2 - float3(0, 0, _focalLength)

public var _viewRadius: Float = 5.0
public var _viewAngle: Float = 1

public var renderConfig = RenderConfig(imageWidth: _imageWidth,
                                       imageHeight: _imageHeight,
                                       aspectRatio: _aspectRatio,
                                       gameTime: 0,
                                       samplesPerPixel: _samplesPerPixel,
                                       maxDepth: _maxDepth,
                                       tickSeed: 1,
                                       viewportHeight: _viewportHeight,
                                       viewportWidth: _viewportWidth,
                                       focalLength: _focalLength,
                                       vfov: 50.0,
                                       origin: _origin,
                                       horizontal: _horizontal,
                                       vertical: _vertical,
                                       lowerLeftCorner: _lowerLeftCorner,
                                       lookfrom: float3(0, 2, 0),
                                       lookat: float3(0, 0.4, 2),
                                       vup: float3(0,1,0),
                                       spherePos: float3(1.0, 0.45, -1.0))

public let pixelCount: Int = Int(renderConfig.imageWidth * renderConfig.imageHeight)
