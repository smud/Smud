//
// CommandContext.swift
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

struct CommandContext {
    let args: Arguments
    let player: Player
    let connection: Connection
    let userCommand: String

    var room: Room? { return player.room }
    var area: Area? { return room?.area }
    
    func send(_ items: Any..., separator: String = "", terminator: String = "\n", rfc1123EOLs: Bool = true) {
        connection.send(items: items, separator: separator, terminator: terminator, rfc1123EOLs: rfc1123EOLs)
    }
}
