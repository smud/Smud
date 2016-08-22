//
// RoomEditorCommands.swift
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

class RoomEditorCommands {
    static func register(with router: CommandRouter) {
        router["room list"] = roomList
        router["room new"] = roomNew
        router["room"] = room
    }

    static func roomList(context: CommandContext) throws -> CommandAction {
        let areaTag: String
        
        if let tag = context.args.scanTag() {
            if tag.isQualified {
                context.send("Expected area name only.")
                return .accept
            }
            areaTag = tag.object
        } else {
            context.send("No area specified.")
            return .accept
        }
        
        context.send("List of #\(areaTag) room templates:")
        let rooms = RoomManager.areaTemplates[areaTag]?.map { k, v in
            "  #\(v.primaryTag)" }.joined(separator: "\n") ?? ""
        context.send(rooms.isEmpty ? "  none." : rooms)
        return .accept
    }
    
    static func roomNew(context: CommandContext) throws -> CommandAction {
        guard let tag = context.args.scanTag() else {
            return .showUsage("Usage: room new #tag Short description")
        }
        let roomName = context.args.scanRestOfString() ?? "Unnamed room"
        
        do {
            let roomTemplate = try RoomManager.createRoomTemplate(tag: tag, player: context.player)
        } catch let error as RoomManagerError {
            context.send(error)
            return .accept
        }
        
        

        return .accept
    }
    
    static func room(context: CommandContext) -> CommandAction {
        var result = ""
        if let subcommand = context.args.scanWord() {
            result += "Unknown subcommand: \(subcommand)\n"
        }
        result += "Available subcommands: new"
        return .showUsage(result)
    }
}
