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
    public let area: Area
    public let index: Int
    public var roomsById = [String: Room]()
    public var areaMap = AreaMap()
    
    public var pluginsData = [ObjectIdentifier: AnyObject]()

    public init(area: Area, index: Int) {
        self.area = area
        self.index = index
        spawnRooms()
    }
    
    func spawnRooms() {
        for (roomId, room) in area.prototype.rooms {
            let room = Room(prototype: room, instance: self)
            roomsById[roomId] = room
            
            room.reset()
        }
    }
    
    func buildMap() {
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
