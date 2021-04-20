//
//  Keyboard.swift
//  GameEngine
//
//  Created by 徐浩博 on 2020/11/20.
//

import Foundation

public class Keyboard {
    private static var KEY_COUNT = 256
    private static var keys = [Bool].init(repeating: false, count: KEY_COUNT)
    
    public static func SetKeyPress(_ keyCode: UInt16, isOn: Bool) {
        keys[Int(keyCode)] = isOn
    }
    
    public static func ISKeyPressed(_ keyCode: KeyCodes) -> Bool {
        return keys[Int(keyCode.rawValue)]
    }
}
