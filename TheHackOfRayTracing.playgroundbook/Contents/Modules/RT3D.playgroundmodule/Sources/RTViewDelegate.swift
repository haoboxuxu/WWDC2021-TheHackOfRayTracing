//
//  RTViewDelegate.swift
//  MTKRenderLoop
//
//  Created by 徐浩博 on 2021/4/2.
//

import MetalKit
import Metal
import UIKit

public class RTViewDelegate: NSObject {
    
    var view: MTKView!
    
    private var computePipelineState: MTLComputePipelineState!
    private var drawPixelFunc: MTLFunction!
    
    private var width : Int!
    private var height : Int!
    
    public static var ScreenSize: float2 = float2(0, 0)
    public static var AspectRatio: Float {
        return ScreenSize.x / ScreenSize.y
    }
    
    var sceneOption: Int = 0 // 0: openScene, 1: rtDayScene, 2: rtNightScene
    
    public init(mtkView: MTKView, option: Int) {
        super.init()
        
        self.sceneOption = option
        view = mtkView
        
        view.device = MTLCreateSystemDefaultDevice()
        
        view.framebufferOnly = false
        view.colorPixelFormat = .bgra8Unorm
        
        if view.device == nil {
            print("Metal Is Not Supported On This Device")
            return
        }
        
        width = Int(_imageWidth)
        height = Int(_imageHeight)
        
        // Create default library and commandqueue
        RTEngine.Ignite(device: view!.device!)
        
        view!.preferredFramesPerSecond = 30
        
        view.delegate = self
        setupComputePipeline()
        
    }
}


extension RTViewDelegate: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.width  = Int(view.drawableSize.width)
        self.height = Int(view.drawableSize.height)
    }
    
    public func draw(in view: MTKView) {
        update(in: view)
        // do render config update
        renderConfig.gameTime += 1.0/30.0
        renderConfig.tickSeed += 1
        renderConfig.lookfrom.x = cos(_viewAngle) * _viewRadius
        renderConfig.lookfrom.z = sin(_viewAngle) * _viewRadius
    }
}

extension RTViewDelegate {
    fileprivate func update(in view: MTKView) {
        
        let commandBuffer = RTEngine.CommandQuque.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        // If the commandEncoder could not be made
        if commandEncoder == nil || commandBuffer == nil {
            return
        }
        
        
        // If drawable is not ready, don't draw
        guard let drawable = view.currentDrawable else {
            commandEncoder!.endEncoding()
            commandBuffer!.commit()
            return
        }
        
        commandEncoder!.setBytes(&renderConfig, length: MemoryLayout<RenderConfig>.stride, index: 0)
        commandEncoder!.setTexture(view.currentDrawable?.texture , index: 0)
        self.dispatchPipelineState(using: commandEncoder!)
        
        commandEncoder!.endEncoding()
        commandBuffer!.present(drawable)
        commandBuffer!.commit()
    }
    
    fileprivate func dispatchPipelineState(using commandEncoder: MTLComputeCommandEncoder) {
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        let threadgroupsPerGrid = MTLSize(width: (self.width + w - 1) / w, height: (self.height + h - 1) / h, depth: 1)
        
        commandEncoder.setComputePipelineState(computePipelineState)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    private func setupComputePipeline() {
        var library: MTLLibrary = try! RTEngine.Device.makeLibrary(source: rainbowShader, options: nil)
        if self.sceneOption == 0 {
            library = try! RTEngine.Device.makeLibrary(source: rainbowShader, options: nil)
            renderConfig.lookfrom = float3(0, 0, 2)
            renderConfig.lookat = float3(0, 0, 0)
        }else if self.sceneOption == 1 {
            library = try! RTEngine.Device.makeLibrary(source: rtShaderDay, options: nil)
        } else if self.sceneOption == 2 {
            library = try! RTEngine.Device.makeLibrary(source: rtShaderNight, options: nil)
        }
        
        self.drawPixelFunc = library.makeFunction(name:"draw_pixel_func")!
        do {
            try computePipelineState = RTEngine.Device.makeComputePipelineState(function: drawPixelFunc)
        } catch {
            fatalError("ComputePipelineState failed")
        }
    }
}
