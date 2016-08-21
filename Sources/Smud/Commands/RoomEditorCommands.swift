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
        router["room new"] = roomNew
    }

    static func roomNew(context: CommandContext) throws -> CommandAction {
        guard let tag = context.args.scanTag() else {
            return .showUsage("Usage: room new #tag Short description")
        }
        let roomName = context.args.scanRestOfString() ?? "Unnamed room"
        
//        guard tags.count == 1 else {
//            context.send()
//            return .accept
//        }
//        let tag = tags.first!
//        
//        var path = tag.components(separatedBy: ".")
//        guard let roomTag = path.popLast() else {
//            context.send("Please specify a room tag.")
//            return .accept
//        }
//        
//        var area: Area?
//        
//        if let areaTag = path.popLast() {
//            area = AreaManager.areas[areaTag]
//            guard area != nil else {
//                context.send("Area #\(areaTag) does not exist.")
//                return .accept
//            }
//        } else {
//            context.send("Please specify area name: #area_tag.room_tag")
//            return .accept
//        }
//        
//        
//        let roomTemplate = RoomTemplate(
//        
        return .accept
    }
}
