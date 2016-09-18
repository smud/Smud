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
//        router["room new"] = roomNew
//        router["room"] = room
    }

    static func roomList(context: CommandContext) throws -> CommandAction {
        let area: Area
        
        if let tag = context.args.scanTag() {
            if tag.isQualified {
                context.send("Expected area name only: #areaname")
                return .accept
            }

            guard let v = Area.with(primaryTag: tag.object) else {
                context.send("Area tagged \(tag) does not exist.")
                return .accept
            }
            area = v

        } else if let room = context.player.room, let v = room.area {
            area = v
            
        } else {
            context.send("No area tag specified and you aren't standing in any room.")
            return .accept
        }
        
        
        context.send("List of #\(area.primaryTag) room templates:")
        let templates = area.roomTemplatesByTag.map { k, v in
                "  #\(k)"
            }.joined(separator: "\n")
        context.send(templates.isEmpty ? "  none." : templates)
        return .accept
    }
    
//    static func roomNew(context: CommandContext) throws -> CommandAction {
//        guard let tag = context.args.scanTag() else {
//            return .showUsage("Usage: room new #tag Short description")
//        }
//        let roomName = context.args.scanRestOfString() ?? "Unnamed room"
//        
//        do {
//            let roomTemplate = try RoomManager.createRoomTemplate(tag: tag, player: context.player)
//        } catch let error as RoomManagerError {
//            context.send(error)
//            return .accept
//        }
//        
//        
//
//        return .accept
//    }
    
//    static func room(context: CommandContext) -> CommandAction {
//        var result = ""
//        if let subcommand = context.args.scanWord() {
//            result += "Unknown subcommand: \(subcommand)\n"
//        }
//        result += "Available subcommands: new"
//        return .showUsage(result)
//    }
}
