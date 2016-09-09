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
    var server: Server

    init(server: Server) {
        self.server = server
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
        sin.sin_port = port.bigEndian
        
        var bind_addr = sockaddr()
        memcpy(&bind_addr, &sin, Int(MemoryLayout<sockaddr_in>.size))
        
        let context = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        listener = evconnlistener_new_bind(eventBase,
            { listener, fd, address, socklen, ctx in
                let target = unsafeBitCast(ctx, to: ConnectionListener.self)
                target.onAccept(listener: listener, fd: fd, address: address, socklen: socklen)
            },
            context,
            LEV_OPT_CLOSE_ON_FREE | LEV_OPT_REUSEABLE,
            -1,
            &bind_addr,
            Int32(MemoryLayout<sockaddr_in>.size))
        if listener == nil {
            throw SystemError("Couldn't create listener")
        }
        evconnlistener_set_error_cb(listener) { listener, ctx in
            let target = unsafeBitCast(ctx, to: ConnectionListener.self)
            target.onAcceptError(listener: listener)
        }
        print("Ready to accept connections on port \(port)")
    }
 
    func onAccept(listener: OpaquePointer?, fd: Int32, address: UnsafeMutablePointer<sockaddr>?, socklen: Int32) {
        
        var addressString = ""
        
        if let address = address {
            let addressOpaquePointer = OpaquePointer(address)
            if let sin = UnsafePointer<sockaddr_in>(addressOpaquePointer)?.pointee,
                let addressCString = inet_ntoa(sin.sin_addr) {
                    addressString = String(cString: addressCString)
                    print("New connection: \(addressString)")
            }
        }
        
        let base = evconnlistener_get_base(listener)
        let bevSocket = bufferevent_socket_new(base, fd, Int32(BEV_OPT_CLOSE_ON_FREE.rawValue))
        guard let bev = bevSocket else {
            print("Unable to accept connection")
            return
        }

        let connection = Connection(bufferEvent: bev)
        connection.address = addressString
        //connection.send("Hello")
        server.newConnection(connection)
    }
    
    func onAcceptError(listener: OpaquePointer?) {
        //let base = evconnlistener_get_base(listener)
        let err = EVUTIL_SOCKET_ERROR_I()
        let textCString = evutil_socket_error_to_string_i(err)
        let text = String(cString: textCString)
        
        print("Error \(err) (\(text)), closing connection.")
    }
}
