//
// MovementCommands.swift
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

class MovementCommands {
    static func register(with router: CommandRouter) {
        router["go"] = go
    }

    static func go(context: CommandContext) -> CommandAction {
        guard let tag = context.args.scanTag() else {
            return .showUsage("Usage: go #room")
        }
        
        guard let room = context.findRoom(tag: tag) else { return .accept }
        
        context.player.room = room
     
        guard let area = room.area else { return .accept }
        
        context.send("Relocated to #\(area).\(room.primaryTag):\(room.instanceIndex)")
        return .accept
    }
}
