//
//  SmudPlugin.swift
//  DemoMUD
//
//  Created by Andrey Fidrya on 17/12/16.
//
//

import Foundation

public protocol SmudPlugin {
    func willEnterGameLoop()
}

extension SmudPlugin {
    public func willEnterGameLoop() { }
}
