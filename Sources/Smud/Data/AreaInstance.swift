//
// AreaInstance.swift
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

public class AreaInstance {
    public enum ResetMode {
        case forPlaying
        case forEditing
    }

    public let area: Area
    public let index: Int
    public var roomsById = [String: Room]()
    public var areaMap = AreaMap()
    public var resetMode: ResetMode

    public var pluginsData = [ObjectIdentifier: AnyObject]()

    public init(area: Area, index: Int, mode: ResetMode = .forPlaying) {
        self.area = area
        self.index = index
        self.resetMode = mode
        spawnRooms(mode: mode)
    }
    
    func spawnRooms(mode: ResetMode) {
        for (roomId, room) in area.prototype.roomsById {
            let room = Room(prototype: room, instance: self)
            roomsById[roomId] = room
            
            room.reset(mode: mode)
        }
    }

    public func digRoom(from fromRoom: Room, direction: Direction, id: String) -> Room? {
        guard fromRoom.areaInstance == self else {
            assertionFailure()
            return nil
        }

        guard id != fromRoom.id else { return nil }
        guard fromRoom.exits[direction] == nil else { return nil }

        let room: Room
        if let existingRoom = roomsById[id] {
            guard existingRoom.resolveExit(direction: direction.opposite) != fromRoom else { return existingRoom }
            guard existingRoom.exits[direction.opposite] == nil else { return nil }
            room = existingRoom
        } else {
            room = Room(id: id, instance: self)
            roomsById[id] = room
            let area = room.areaInstance.area
            area.prototype.roomsById[id] = room.prototype
        }

        fromRoom.exits[direction] = Link(room: room)
        fromRoom.prototype.replace(name: "exit.\(direction.rawValue)", value: .link(Link(room: room)))
        room.exits[direction.opposite] = Link(room: fromRoom)
        room.prototype.replace(name: "exit.\(direction.opposite)", value: .link(Link(room: fromRoom)))
        
        _ = areaMap.dig(toRoom: room, fromRoom: fromRoom, direction: direction)

        area.scheduleForSaving()
        
        return room
    }

    public func buildMap() {
        if let room = roomsById.first?.value {
            print("Bulding map for area instance #\(area.id):\(index): starting room: #\(room.id)")
            let mapper = AreaMapper()
            areaMap = mapper.buildAreaMap(startingRoom: room)
            print("  \(areaMap.roomsCount) room(s), \(areaMap.elementsCount) map element(s)")
            print(areaMap.debugPrint())
        } else {
            areaMap = AreaMap()
        }    
    }
    
    public func pluginData<Type>(id: ObjectIdentifier = ObjectIdentifier(Type.self)) -> Type where Type: PluginData, Type.Parent == AreaInstance {
        if let data = pluginsData[id] as? Type {
            return data
        } else {
            let data = Type(parent: self)
            pluginsData[id] = data
            return data
        }
    }
}

extension AreaInstance: Equatable {
    public static func ==(lhs: AreaInstance, rhs: AreaInstance) -> Bool {
        return lhs.area.id == rhs.area.id &&
            lhs.index == rhs.index
    }
}
