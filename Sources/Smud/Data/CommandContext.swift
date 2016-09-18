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

    func findArea(tag: Tag?) -> Area? {
        if let tag = tag {
            if tag.isQualified {
                send("Expected area name only: #areaname")
                return nil
            }
            
            guard let v = Area.with(primaryTag: tag.object) else {
                send("Area tagged \(tag) does not exist.")
                return nil
            }
            return v
            
        } else if let v = area {
            return v
            
        } else {
            send("No area tag specified and you aren't standing in any room.")
            return nil
        }
    }
    
    func findRoom(tag: Tag?) -> Room? {
        guard let tag = tag else { return room }
        
        var targetArea: Area
        if let areaTag = tag.area {
            guard let v = Area.with(primaryTag: areaTag) else {
                send("Area tagged #\(areaTag) does not exist.")
                return nil
            }
            targetArea = v
        } else if let v = area {
            targetArea = v
        } else {
            send("No area tag specified and you aren't standing in any room.")
            return nil
        }
        
        var targetInstance: Int
        if let instanceIndex = tag.instance {
            targetInstance = instanceIndex
        } else if let v = room?.instanceIndex {
            targetInstance = v
        } else {
            send("Please specify an instance index.")
            return nil
        }
        
        guard let instance = targetArea.instances[targetInstance] else {
            send("Instance \(targetInstance) does not exist.")
            return nil
        }
        
        guard let room = instance.roomsByTag[tag.object] else {
            send("Room \(tag) does not exist.")
            return nil
        }
        
        return room
    }
    
    func send(_ items: Any..., separator: String = "", terminator: String = "\n", rfc1123EOLs: Bool = true) {
        connection.send(items: items, separator: separator, terminator: terminator, rfc1123EOLs: rfc1123EOLs)
    }
}
