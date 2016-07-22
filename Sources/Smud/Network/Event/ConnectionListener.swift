//
// ConnectionListener.swift
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

class ConnectionListener {
    let eventBase: OpaquePointer?
    var listener: OpaquePointer?

    init(server: Server) {
        self.eventBase = server.eventBase.eventBase
        self.listener = nil
    }
    
    deinit {
        if let listener = self.listener {
            evconnlistener_free(listener)
        }
    }
        
    func listen(port: UInt16) throws {
        var sin = sockaddr_in()
        //sin.sin_len = UInt8(sizeofValue(sockaddr_in))
        sin.sin_family = sa_family_t(AF_INET)
        sin.sin_addr = in_addr(s_addr: inet_addr("0.0.0.0"))
        sin.sin_port = Int(OSHostByteOrder()) == OSLittleEndian ? _OSSwapInt16(port) : port
        
        var bind_addr = sockaddr()
        memcpy(&bind_addr, &sin, Int(sizeofValue(sin)))
        
        let context = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
        listener = evconnlistener_new_bind(eventBase,
            { listener, fd, address, socklen, ctx in
                let target = unsafeBitCast(ctx, to: ConnectionListener.self)
                target.onAccept(listener: listener, fd: fd, address: address, socklen: socklen)
            },
            context,
            LEV_OPT_CLOSE_ON_FREE | LEV_OPT_REUSEABLE,
            -1,
            &bind_addr,
            Int32(sizeofValue(sin)))
        if listener == nil {
            throw SystemError("Couldn't create listener")
        }
        evconnlistener_set_error_cb(listener) { listener, ctx in
            let target = unsafeBitCast(ctx, to: ConnectionListener.self)
            target.onAcceptError(listener: listener)
        }
    }
    
 
    func onAccept(listener: OpaquePointer?, fd: Int32, address: UnsafeMutablePointer<sockaddr>?, socklen: Int32) {
        if let address = address {
            if let sin = UnsafePointer<sockaddr_in>(address)?.pointee,
                let addressCString = inet_ntoa(sin.sin_addr) {
                    let addressString = String(cString: addressCString)
                print("New connection: \(addressString)")
            }
        }
        
        let base = evconnlistener_get_base(listener)
        let bevSocket = bufferevent_socket_new(base, fd, Int32(BEV_OPT_CLOSE_ON_FREE.rawValue))
        guard let bev = bevSocket else {
            print("Unable to accept connection")
            return
        }
        
        let context = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
        bufferevent_setcb(bev,
            /* read */ { bev, ctx in
                let target = unsafeBitCast(ctx, to: ConnectionListener.self)
                target.onRead(bev: bev)
            },
            /* write */ { bev, ctx in
                let target = unsafeBitCast(ctx, to: ConnectionListener.self)
                target.onWrite(bev: bev)
            },
            /* event */ { bev, events, ctx in
                let target = unsafeBitCast(ctx, to: ConnectionListener.self)
                target.onEvent(bev: bev, events: events)
            },
            /* cbarg */ context)
        bufferevent_enable(bev, Int16(EV_READ)|Int16(EV_WRITE))

        let connection = Connection(bufferEvent: bev)
        connection.send("Hello")
    }
    
    func onAcceptError(listener: OpaquePointer?) {
        //let base = evconnlistener_get_base(listener)
        let err = EVUTIL_SOCKET_ERROR_I()
        let textCString = evutil_socket_error_to_string_i(err)
        let text = String(cString: textCString)
        
        print("Error \(err) (\(text)), closing connection.")
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
            bufferevent_free(bev);
        }
    }
}
