//
// Room.swift
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

public class Room {
    public let prototype: Entity
    public var areaInstance: AreaInstance
    
    public var id: String
    public var title: String
    public var exits = [Direction: Link]()
    
    public var orderedExits: [(Direction, Link)] {
        var result = [(Direction, Link)]()
        for direction in Direction.orderedDirections {
            guard let exit = exits[direction] else { continue }
            result.append((direction, exit))
        }
        return result
    }
    
    public init(prototype: Entity, instance: AreaInstance) {
        self.prototype = prototype
        self.areaInstance = instance

        let id = prototype["room"]?.string ?? ""
        assert(id != "")
        self.id = id
        
        title = prototype["title"]?.string ?? "No title"
    }
    
    public func reset() {
        exits.removeAll(keepingCapacity: true)
        
        if let lastExitIndex = prototype.lastStructureIndex["exit"] {
            for i in 0...lastExitIndex {
                if let north = prototype["exit.north", i]?.link {
                    exits[.north] = north
                }
                if let east = prototype["exit.east", i]?.link {
                    exits[.east] = east
                }
                if let south = prototype["exit.south", i]?.link {
                    exits[.south] = south
                }
                if let west = prototype["exit.west", i]?.link {
                    exits[.west] = west
                }
                if let up = prototype["exit.up", i]?.link {
                    exits[.up] = up
                }
                if let down = prototype["exit.down", i]?.link {
                    exits[.down] = down
                }
            }
        }
    }
    
    public func resolveExit(direction: Direction) -> Room? {
        guard let link = exits[direction] else { return nil }
        return resolveLink(link: link)
    }
    
    public func resolveLink(link: Link) -> Room? {
        let roomId = link.object
        if let areaId = link.parent {
            guard let area = areaInstance.area.world.areasById[areaId] else {
                return nil
            }
            guard let instance = area.instancesByIndex.first?.value else {
                return nil
            }
            return instance.roomsById[roomId]
        } else {
            return areaInstance.roomsById[roomId]
        }
    }
}

extension Room: Equatable {
    public static func ==(lhs: Room, rhs: Room) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Room: Hashable {
    public var hashValue: Int { return id.hashValue }
}
