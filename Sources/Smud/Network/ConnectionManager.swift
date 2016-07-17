//
// ConnectionManager.swift
//
// This source file is part of the SMUD open source project
//
// Copyright (c) 2016 SMUD project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SMUD project authors
//

import Foundation

class ConnectionManager {
   
    init?() {
        let version = eventGetVersion()
        print("Libevent version: \(version)")
        
        let methods = eventGetSupportedMethods().joined(separator: ", ")
        print("Supported methods: \(methods)")
        
        guard let eventBase = EventBase() else { return nil }

        let method = eventBase.getMethod()
        print("Using method: \(method)")
        
        let features = eventBase.getFeatures()
        let edgeTriggered = (features & evFeatureET) != 0
        print("Edge triggered events: \(edgeTriggered ? "YES" : "NO")")
        
        let o1 = (features & evFeatureO1) != 0
        print("O(1) event notification: \(o1 ? "YES" : "NO")")
        
        let fds = (features & evFeatureFDS) != 0
        print("All FD types: \(fds ? "YES" : "NO")")
    }
}

