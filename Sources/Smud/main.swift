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

var terminated = false
guard let connectionManager = ConnectionManager() else { exit(1) }

DispatchQueue.main.after(when: DispatchTime.now() + 3) {
    print("3 seconds passed")
    terminated = true
}

while !terminated {
    switch connectionManager.loop() {
    case 1:
        break // Just idling
    case 0:
        print("Libevent: processed event(s)")
    default: // -1
        print("Unhandled error in network backend")
        exit(1)
    }
    RunLoop.current().run(mode: RunLoopMode.defaultRunLoopMode,
                          before: Date(timeIntervalSinceNow: 0.01))
}

print("Quitting")
