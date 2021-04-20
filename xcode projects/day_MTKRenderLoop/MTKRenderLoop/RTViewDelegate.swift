//
//  RTViewDelegate.swift
//  MTKRenderLoop
//
//  Created by 徐浩博 on 2021/4/2.
//

import Cocoa
import Metal
import MetalKit

public class RTViewDelegate: NSViewController {
    
    var metalView: MTKView?
    
    private var computePipelineState: MTLComputePipelineState!
    private var drawPixelFunc: MTLFunction!
    
    private var width : Int!
    private var height : Int!
    
    public static var ScreenSize: float2 = float2(0, 0)
    public static var AspectRatio: Float {
        return ScreenSize.x / ScreenSize.y
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.metalView = self.view as? MTKView
        self.metalView?.device = MTLCreateSystemDefaultDevice()
        
        metalView?.framebufferOnly = false
        metalView?.colorPixelFormat = .bgra8Unorm
        
        if metalView?.device == nil {
            print("This Device doesn't support Metal")
            return
        }
        
        self.width = Int(renderConfig.imageWidth)
        self.height = Int(renderConfig.imageHeight)
        
        // Create default library and commandqueue
        RTEngine.Ignite(device: self.metalView!.device!)
        
        self.metalView!.delegate = self
        self.metalView!.preferredFramesPerSecond = 30
        
        self.setupComputePipeline()
    }
}

extension RTViewDelegate: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.width  = Int(view.drawableSize.width)
        self.height = Int(view.drawableSize.height)
    }
    
    public func draw(in view: MTKView) {
        self.update(in: view)
        // do render config update
        updateInputs()
        renderConfig.gameTime += 1.0/30.0
        renderConfig.tickSeed += 1
        renderConfig.lookfrom.x = cos(_viewAngle) * _viewRadius
        renderConfig.lookfrom.z = sin(_viewAngle) * _viewRadius
    }
}

extension RTViewDelegate {
    func update(in view: MTKView) {
        
        let commandBuffer = RTEngine.CommandQuque.makeCommandBuffer()
        
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        if commandEncoder == nil || commandBuffer == nil {
            print("CommandEncoder support failed")
            return
        }
        
        guard let drawable = view.currentDrawable else {
            commandEncoder!.endEncoding()
            commandBuffer!.commit()
            print("Drawable is not ready")
            return
        }
        
        commandEncoder!.setBytes(&renderConfig, length: MemoryLayout<RenderConfig>.stride, index: 0)
        commandEncoder!.setTexture(view.currentDrawable?.texture , index: 0)
        self.dispatchPipelineState(using: commandEncoder!)
        
        commandEncoder!.endEncoding()
        commandBuffer!.present(drawable)
        commandBuffer!.commit()
    }
    
    func dispatchPipelineState(using commandEncoder: MTLComputeCommandEncoder) {
        let w = computePipelineState.threadExecutionWidth
        let h = computePipelineState.maxTotalThreadsPerThreadgroup / w
        let threadsPerThreadgroup = MTLSizeMake(w, h, 1)
        
        let threadgroupsPerGrid = MTLSize(width: (self.width + w - 1) / w,
                                          height: (self.height + h - 1) / h,
                                          depth: 1)
        
        commandEncoder.setComputePipelineState(computePipelineState)
        commandEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
    }
    
    func setupComputePipeline() {
        self.drawPixelFunc = RTEngine.DefaltLibrary.makeFunction(name: "draw_pixel_func")
        do {
            try computePipelineState = RTEngine.Device.makeComputePipelineState(function: drawPixelFunc)
        } catch {
            print("ComputePipelineState failed")
            return
        }
    }
}

// handle inputs
extension RTViewDelegate {
    func updateInputs() {
        if Gestures.touched {
            _viewAngle += Float(Gestures.mx)
            if renderConfig.lookfrom.y + Float(Gestures.my) >= 0.1 {
                renderConfig.lookfrom.y += Float(Gestures.my)
            }
        }
        
        if Keyboard.ISKeyPressed(.leftArrow) {
            _viewAngle += 0.1
        }
        
        if Keyboard.ISKeyPressed(.rightArrow) {
            _viewAngle -= 0.1
        }
        
        if Keyboard.ISKeyPressed(.upArrow) {
            renderConfig.lookfrom.y += 0.1
        }
        
        if Keyboard.ISKeyPressed(.downArrow) {
            if renderConfig.lookfrom.y >= 0.1 {
                renderConfig.lookfrom.y -= 0.1
            }
        }
        
        if Mouse.IsMouseButtonPressed(button: .right) {
            renderConfig.vfov += 1
        }
        
        if Mouse.IsMouseButtonPressed(button: .left) {
            renderConfig.vfov -= 1
        }
        
        if Keyboard.ISKeyPressed(.w) {
            renderConfig.spherePos.x += 0.1
        }
        if Keyboard.ISKeyPressed(.s) {
            renderConfig.spherePos.x -= 0.1
        }
        if Keyboard.ISKeyPressed(.a) {
            renderConfig.spherePos.z -= 0.1
        }
        if Keyboard.ISKeyPressed(.d) {
            renderConfig.spherePos.z += 0.1
        }
        
    }
}
