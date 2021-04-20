//
//  File.swift
//  GameEngine
//
//  Created by 徐浩博 on 2020/11/18.
//

import MetalKit

public class RTEngine {
    public static var Device: MTLDevice!
    public static var CommandQuque: MTLCommandQueue!
    public static var DefaltLibrary: MTLLibrary!
    
    public static func Ignite(device: MTLDevice) {
        self.Device = device
        self.CommandQuque = device.makeCommandQueue()
        self.DefaltLibrary = device.makeDefaultLibrary()
    }
}
