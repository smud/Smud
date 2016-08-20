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
#if os(Linux)
import CoreFoundation
#endif

var terminated = false

func main() {
    print("Smud starting")
    
    print("Checking if database is up to date")
    do {
        try MigrationController.migrate()
    } catch {
        print("Error while migrating the database: \(error)")
        exit(1)
    }
    
    print("Loading areas")
    do {
        try AreaManager.loadAreas()
    } catch {
        print("Error while loading areas: \(error)")
        exit(1)
    }
    
    print("Registering connection contexts")
    ConnectionContextBuilder.registerContexts()
    
    print("Registering commands")
    Commands.register()
    
    guard let server = Server() else { exit(1) }

    let listener = ConnectionListener(server: server)
    do {
        try listener.listen(port: 4000)
    } catch {
        print(error)
        exit(1)
    }

    let maxLatencySeconds = 0.01

    print("Ready to accept connections")
    #if os(OSX)
    while !terminated {
        switch server.loop() {
        case 1: break // Just idling
        case 0: break //print("Libevent: processed event(s)")
        default: // -1
            print("Unhandled error in network backend")
            exit(1)
        }
        let success = RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode,
                                          before: Date(timeIntervalSinceNow: maxLatencySeconds))
        guard success else {
            print("Unable to start RunLoop")
            exit(1)
        }
    }
    #else
    let queue = dispatch_get_main_queue()
    let timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue)
    let interval = maxLatencySeconds
    let block: () -> () = {
        guard !terminated else {
            print("Quitting")
            exit(0)
        }
        switch server.loop() {
        case 1: break // Just idling
        case 0: break //print("Libevent: processed event(s)")
        default: // -1
            print("Unhandled error in network backend")
            exit(1)
        }
    }
    block()
    let fireTime = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
    dispatch_source_set_timer(timer, fireTime, UInt64(interval * Double(NSEC_PER_SEC)), UInt64(NSEC_PER_SEC) / 10)
    dispatch_source_set_event_handler(timer, block)
    dispatch_resume(timer)
    dispatch_main()
    #endif
}

main()
print("Quitting")

