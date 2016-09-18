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
        let templates = area.roomTemplates.byTag.map { k, v in
            if let name = v.getSetter(named: "name")?.value.areaFormat {
                return "  #\(k) \(name)"
            } else {
                return "  #\(k)"
            }
        }.joined(separator: "\n")
        context.send(templates.isEmpty ? "  none." : templates)
        return .accept
    }
    
    static func roomNew(context: CommandContext) throws -> CommandAction {
        guard let tag = context.args.scanTag() else {
            return .showUsage("Usage: room new #tag Short description")
        }
        let roomName = context.args.scanRestOfString()
        
        guard let areaTag = tag.area ?? context.area?.primaryTag else {
            context.send("No area tag specified and you aren't standing in any room.")
            return .accept
        }
        
        guard let area = Area.with(primaryTag: areaTag) else {
            context.send("Area tagged #\(areaTag) does not exist.")
            return .accept
        }
        
        guard nil == area.roomTemplates.byTag[tag.object] else {
            context.send("Room template tagged \(tag) aleady exists.")
            return .accept
        }
        
        let template = Template()
        if let roomName = roomName {
            template.append(setter: Template.Setter("name", roomName))
        }
        area.roomTemplates.byTag[tag.object] = template
        area.modified = true

        context.send("Room template created: \(tag)")
        return .accept
    }
    
    static func room(context: CommandContext) -> CommandAction {
        var result = ""
        if let subcommand = context.args.scanWord() {
            result += "Unknown subcommand: \(subcommand)\n"
        }
        result += "Available subcommands: list new"
        return .showUsage(result)
    }
}
