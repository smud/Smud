//
// Telnet.swift
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

/// RFC854
enum TelnetCommand: UInt8 {
    case subnegotiationEnd = 240
    case noOperation = 241
    case dataMark = 242
    case breakKey = 243
    case interruptProcess = 244
    case abortOutput = 245
    case areYouThere = 246
    case eraseCharacter = 247
    case eraseLine = 248
    case goAhead = 249
    case subnegotiationBegin = 250
    case willOption = 251
    case wontOption = 252
    case doOption = 253
    case dontOption = 254
    case interpretAsCommand = 255
}

enum TelnetOption: UInt8 {
    case binary = 0
    case echo = 1
}
