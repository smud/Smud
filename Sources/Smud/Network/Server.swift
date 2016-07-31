//
// Server.swift
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
import CEvent

class Server {
    let eventBase: EventBase
    var connections = [OpaquePointer: Connection]()
    
    init?() {
        let version = eventGetVersion()
        print("Libevent version: \(version)")
        
        let methods = eventGetSupportedMethods().joined(separator: ", ")
        print("Supported methods: \(methods)")
        
        guard let eventBase = EventBase() else { return nil }
        self.eventBase = eventBase

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
    
    func loop() -> Int32 {
        return eventBase.loop(flags: evloopNonblock)
    }
    
    func newConnection(_ connection: Connection) {
        connections[connection.bufferEvent] = connection
        
        let context = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
        let bev = connection.bufferEvent
        bufferevent_setcb(bev,
            /* read */ { bev, ctx in
                let target = unsafeBitCast(ctx, to: Server.self)
                target.onRead(bev: bev)
            },
            /* write */ { bev, ctx in
                let target = unsafeBitCast(ctx, to: Server.self)
                target.onWrite(bev: bev)
            },
            /* event */ { bev, events, ctx in
                let target = unsafeBitCast(ctx, to: Server.self)
                target.onEvent(bev: bev, events: events)
            },
            /* cbarg */ context)
        bufferevent_enable(bev, Int16(EV_READ)|Int16(EV_WRITE))
        
        //connection.send(logo)
        connection.context = ChooseAccountContext()
    }
    
    
    func onRead(bev: OpaquePointer?) {
        print("onRead")
        guard let bev = bev else { return }
        //let input = bufferevent_get_input(bev)
        //let output = bufferevent_get_output(bev)
        let connection = Connection(bufferEvent: bev)
        while let line = connection.readLine() {
            print("Got line: \(line)")
            connection.send("Got line: \(line)")
        }
    }
    
    func onWrite(bev: OpaquePointer?) {
        print("onWrite")
    }
    
    func onEvent(bev: OpaquePointer?, events: Int16) {
        print("onEvent")
        if 0 != events & Int16(BEV_EVENT_ERROR) {
            perror("Error from bufferevent")
        }
        if 0 != events & Int16(BEV_EVENT_EOF) {
            print("Connection closed by remote")
        }
        if (0 != events & (Int16(BEV_EVENT_EOF) | Int16(BEV_EVENT_ERROR))) {
            if let bev = bev {
                connections.removeValue(forKey: bev)
            }
            bufferevent_free(bev);
        }
    }
}

