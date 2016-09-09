//
// TelnetStreamParser.swift
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

class TelnetStreamParser {
    // Skip and react to these sequences:
    // IAC IAC -> IAC
    // IAC [WILL/WONT/DO/DONT] OPTION
    // IAC SB [BYTES] SE
    enum ParseState {
        case data
        case command
        case option
    }
    
    typealias OnLineReady = (_ line: String, _ truncated: Bool)->()
    
    var parseState: ParseState = .data
    var subnegotiationActive = false
    var lineBuffer = [UInt8]()
    var lineTruncated = false
    
    func readLines(buffer: UnsafePointer<UInt8>, count: Int, onLineReady: OnLineReady) {
        for i in 0 ..< count {
            switch parseState {
            case .data:
                switch buffer[i] {
                case TelnetCommand.interpretAsCommand.rawValue:
                    parseState = .command
                default:
                    if !subnegotiationActive {
                        if buffer[i] == 10 {
                            finalizeLine(onLineReady: onLineReady)
                        } else if lineBuffer.count < maximumLineLengthBytes {
                            lineBuffer.append(buffer[i])
                        } else {
                            lineTruncated = true
                        }
                    }
                }
            case .command:
                switch buffer[i] {
                case TelnetCommand.interpretAsCommand.rawValue:
                    lineBuffer.append(buffer[i])
                    parseState = .data
                case TelnetCommand.willOption.rawValue,
                     TelnetCommand.wontOption.rawValue,
                     TelnetCommand.doOption.rawValue,
                     TelnetCommand.dontOption.rawValue:
                    parseState = .option
                case TelnetCommand.subnegotiationBegin.rawValue:
                    subnegotiationActive = true
                    parseState = .data
                case TelnetCommand.subnegotiationEnd.rawValue:
                    subnegotiationActive = false
                    parseState = .data
                default:
                    parseState = .data
                }
                break
            case .option:
                parseState = .data
                break
            }
        }
    }
    
    func finalizeLine(onLineReady: OnLineReady) {
        // Support \r\n line endings as well
        if !lineBuffer.isEmpty && lineBuffer.last == 13 {
            lineBuffer.removeLast()
        }
        lineBuffer.append(0) // Zero-terminated C string
        let line = String(cString: lineBuffer)

        onLineReady(line, lineTruncated)
        
        lineBuffer.removeAll(keepingCapacity: true)
        lineTruncated = false
    }
}
