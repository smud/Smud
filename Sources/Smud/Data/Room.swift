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
    public var description: String
    public var exits = [Direction: Link]()
    public var creatures = [Creature]()
    public let fight: Fight

    public var orderedDirections: [Direction] {
        var result = [Direction]()
        for direction in Direction.orderedDirections {
            guard exits[direction] != nil else { continue }
            result.append(direction)
        }
        return result
    }

    public var orderedExits: [(Direction, Link)] {
        var result = [(Direction, Link)]()
        for direction in Direction.orderedDirections {
            guard let exit = exits[direction] else { continue }
            result.append((direction, exit))
        }
        return result
    }
    
    public init(prototype: Entity, instance: AreaInstance) {
        fight = Fight(smud: instance.area.world.smud)
        self.prototype = prototype
        self.areaInstance = instance

        let id = prototype["room"]?.string ?? ""
        assert(id != "")
        self.id = id
        
        title = prototype["title"]?.string ?? "No title"
        description = prototype["description"]?.string ?? ""
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
        
        if let lastMobileIndex = prototype.lastStructureIndex["load"] {
            for i in 0...lastMobileIndex {
                if let mobileLink = prototype["load.mobile", i]?.link {
                    let count = prototype["load.count", i]?.int ?? 1
                    loadMobiles(link: mobileLink, count: count)
                }
            }
        }
    }
    
    public func resolveExit(direction: Direction) -> Room? {
        guard let link = exits[direction] else { return nil }
        return resolveLink(link: link)
    }
    
    public func resolveLink(link: Link) -> Room? {
        let roomId = link.entity
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
    
    private func loadMobiles(link: Link, count: Int) {
        let world = areaInstance.area.world
        let mobileId = link.entity
        let mobileArea: Area
        if let areaId = link.parent {
            guard let area = world.areasById[areaId] else {
                print("WARNING: area #\(areaId) not found")
                return
            }
            mobileArea = area
        } else {
            mobileArea = areaInstance.area
        }
        guard let mobilePrototype = mobileArea.prototype.mobiles[mobileId] else {
            print("WARNING: mobile prototype \(link) not found")
            return
        }

        for _ in 0 ..< count {
            let mobile = Mobile(prototype: mobilePrototype, world: world)
            world.creatures.append(mobile)
            
            mobile.home = self
            mobile.room = self
            creatures.append(mobile)
        }
    }
}

extension Room: Equatable {
    public static func ==(lhs: Room, rhs: Room) -> Bool {
        //return lhs.id == rhs.id
        return lhs === rhs
    }
}

extension Room: Hashable {
    public var hashValue: Int { return id.hashValue }
}
