//
// Connection.swift
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

class Connection {
    let bufferEvent: OpaquePointer
    let telnetStreamParser = TelnetStreamParser()
    static let promptTerminator: [UInt8] = [TelnetCommand.interpretAsCommand.rawValue, TelnetCommand.goAhead.rawValue]
    
    var context: ConnectionContext? {
        didSet {
            context?.greet(connection: self)
        }
    }
    
    init(bufferEvent: OpaquePointer) {
        self.bufferEvent = bufferEvent
    }
    
    /// Sends the textual representations of `items`, separated by
    /// `separator` and terminated by `terminator` to the remote endpoint.
    ///
    /// The textual representations are obtained for each `item` via
    /// the expression `String(item)`.
    ///
    /// According to RFC 1123, the Telnet end-of-line sequence CR LF
    /// MUST be used to send Telnet data that is not terminal-to-computer
    /// (e.g., for Server Telnet sending output, or the Telnet protocol
    /// incorporated another application protocol). `rfc1123EOLs` option
    /// converts all LFs to CR LF pairs.
    ///
    /// - Note: To print without a trailing newline, pass `terminator: ""`
    ///
    /// - SeeAlso: `debugPrint`, `Streamable`, `CustomStringConvertible`,
    ///   `CustomDebugStringConvertible`
    func send(items: [Any], separator: String = "", terminator: String = "\n", rfc1123EOLs: Bool = true) {
        let output = bufferevent_get_output(bufferEvent)

        let separatorProcessed = rfc1123EOLs ? separator.replacingOccurrences(of: "\n", with: "\r\n") : separator
        let separatorUtf8 = separatorProcessed.utf8
        let separatorData = [UInt8](separatorUtf8)
        let separatorUtf8Count = separatorUtf8.count
        
        var isFirst = true
        for item in items {
            if !isFirst && !separator.isEmpty {
                evbuffer_add(output, separatorData, separatorUtf8Count)
            }
            let text = String(item)
            let textProcessed = rfc1123EOLs ? text.replacingOccurrences(of: "\n", with: "\r\n") : text
            let textUtf8 = textProcessed.utf8
            let data = [UInt8](textUtf8)
            evbuffer_add(output, data, textUtf8.count)
            isFirst = false
        }

        if !terminator.isEmpty {
            let terminatorProcessed = rfc1123EOLs ? terminator.replacingOccurrences(of: "\n", with: "\r\n") : terminator
            let terminatorUtf8 = terminatorProcessed.utf8
            let terminatorData = [UInt8](terminatorUtf8)
            evbuffer_add(output, terminatorData, terminatorUtf8.count)
        }
    }

    func send(_ items: Any..., separator: String = "", terminator: String = "\n", rfc1123EOLs: Bool = true) {
        send(items: items, separator: separator, terminator: terminator, rfc1123EOLs: rfc1123EOLs)
    }

    func sendPrompt(_ items: Any..., separator: String = "", rfc1123EOLs: Bool = true) {
        
        send(items: items, separator: separator, terminator: "", rfc1123EOLs: rfc1123EOLs)
        
        let output = bufferevent_get_output(bufferEvent)
        evbuffer_add(output,
                     Connection.promptTerminator,
                     Connection.promptTerminator.count)
    }

    func readLine() -> String? {
        let input = bufferevent_get_input(bufferEvent)

        var bytesRead: Int = 0
        let result: UnsafeMutablePointer<Int8>? = evbuffer_readln(input, &bytesRead, EVBUFFER_EOL_CRLF)
        guard let cString = result else {
            return nil
        }
        defer { free(cString) }
        return String(cString: cString)
    }
}
