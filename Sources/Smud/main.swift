//
// main.swift
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
import Dispatch

// Run connection manager in a separate thread
DispatchQueue.global(attributes: .qosBackground).async() {
    if let connectionManager = ConnectionManager() {
        while true {
            autoreleasepool {
                connectionManager.dispatch()
            }
        }
    }
}

DispatchQueue.main.after(when: DispatchTime.now() + 3) {
    print("3 seconds passed")
}

DispatchQueue.main.after(when: DispatchTime.now() + 5) {
    print("Stopping")
    CFRunLoopStop(CFRunLoopGetCurrent())
}

DispatchQueue.main.after(when: DispatchTime.now() + 7) {
    print("7 seconds passed")
}

CFRunLoopRun() // RunLoop.current().run()

print("Quitting")
