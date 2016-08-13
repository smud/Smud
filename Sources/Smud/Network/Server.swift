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
    var buffer = [UInt8](repeating: 0, count: 256)
    
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
    
    func closeConnection(_ connection: Connection) {
        connection.close()
        if connection.state == .closed {
            connections.removeValue(forKey: connection.bufferEvent)
        }
    }
    
    func onRead(bev: OpaquePointer?) {
        print("onRead")
        guard let bev = bev else { return }
        guard let connection = connections[bev] else { return }
        //let input = bufferevent_get_input(bev)
        
        buffer.withUnsafeMutableBufferPointer { data in
            //print("data.baseAddress=\(data.baseAddress) data.count=\(data.count)")

            while true {
                let n = bufferevent_read(bev, data.baseAddress, data.count)
                guard n > 0 else { break }
                connection.telnetStreamParser.readLines(
                    buffer: data.baseAddress!, count: n) { line, truncated in
                        if truncated {
                            connection.send("WARNING: Your input was truncated.")
                        }
                        //connection.send("Got line: \(line)")
                        process(line: line, connection: connection)
                }
            }
            
        }
    }
    
    func onWrite(bev: OpaquePointer?) {
        print("onWrite: bev=\(bev)")
        guard let bev = bev else { return }
        guard let connection = connections[bev] else { return }

        if connection.state == .closing && connection.outputLength <= 0 {
            closeConnection(connection)
        }
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
            if let bev = bev, let connection = connections[bev] {
                closeConnection(connection)
            }
            bufferevent_free(bev);
        }
    }
    
    func process(line: String, connection: Connection) {
        connection.hasSentAnything = false
        
        guard let context = connection.context else { return }
        let scanner = Scanner(string: line)
        let args = Arguments(scanner: scanner)
        
        let action: ContextAction
        do {
            action = try context.processResponse(args: args, connection: connection)
        } catch {
            connection.send(internalErrorMessage)
            print("Error in context \(context): \(error)")
            context.greet(connection: connection)
            return
        }
        
        switch action {
        case .retry(let reason):
            if let reason = reason {
                connection.send(reason)
            }
            context.greet(connection: connection)
        case .next(let context):
            connection.context = context
        case .disconnect:
            closeConnection(connection)
        }
        
        if connection.hasSentAnything {
            connection.sendGoAhead()
        }
    }
}

