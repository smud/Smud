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
guard let server = Server() else { exit(1) }

//DispatchQueue.main.after(when: DispatchTime.now() + 3) {
//    print("3 seconds passed")
//    terminated = true
//}

let listener = ConnectionListener(server: server)
do {
    try listener.listen(port: 4000)
} catch {
    print(error)
    exit(1)
}

print("Ready to accept connections")

while !terminated {
    switch server.loop() {
    case 1:
        break // Just idling
    case 0:
        break //print("Libevent: processed event(s)")
    default: // -1
        print("Unhandled error in network backend")
        exit(1)
    }
    RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode,
                        before: Date(timeIntervalSinceNow: 0.01))
}

print("Quitting")
