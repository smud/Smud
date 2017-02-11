//
// Creature+Find.swift
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

public extension Creature {
    public enum FindResult {
        case creature(Creature)
        case item(Item)
        case room(Room)
    }
    
    public struct SearchEntityTypes: OptionSet {
        public let rawValue: Int

        public static let creature = SearchEntityTypes(rawValue: 1 << 0)
        public static let item = SearchEntityTypes(rawValue: 1 << 1)
        public static let room = SearchEntityTypes(rawValue: 1 << 2)

        public init(rawValue: Int) { self.rawValue = rawValue }
    }
    
    public struct SearchLocations: OptionSet {
        public let rawValue: Int
        
        public static let world = SearchLocations(rawValue: 1 << 0)
        public static let room = SearchLocations(rawValue: 1 << 1)
        public static let inventory = SearchLocations(rawValue: 1 << 2)
        public static let equipment = SearchLocations(rawValue: 1 << 3)

        public init(rawValue: Int) { self.rawValue = rawValue }
    }
    
    public func findCreature(selector: EntitySelector, locations: SearchLocations) -> Creature? {
        let result = find(selector: selector, entityTypes: .creature, locations: locations)
        guard let first = result.first,
            case .creature(let creature) = first else {
                return nil
        }
        return creature
    }
    
    public func findOne(selector: EntitySelector, entityTypes: SearchEntityTypes, locations: SearchLocations) -> FindResult? {
        guard selector.startingIndex == 1 && selector.count == 1 else {
            return nil
        }
        let results = find(selector: selector, entityTypes: entityTypes, locations: locations)
        assert(0...1 ~= results.count)
        return results.first
    }
    
    public func find(selector: EntitySelector, entityTypes: SearchEntityTypes, locations: SearchLocations) -> [FindResult] {
        
        guard selector.startingIndex > 0 && selector.count > 0 else { return [] }
        
        // Search What | Search Where | Search Locations (any of them should be set)
        
        // Creature | Self | Room or World
        if entityTypes.contains(.creature), locations.contains(.room) || locations.contains(.world) {
            if case .pattern(let pattern) = selector.type,
                selector.startingIndex == 1,
                selector.count == 1,
                let keyword = pattern.keywords.first,
                keyword.isEqual(toOneOf: ["i", "me", "self"], caseInsensitive: true) {
                    return [.creature(self)]
            }
        }

        var result: [FindResult] = []
        var currentIndex = 1
        
        // Returns true if should continue matching
        let matchAndAppendCreature: (Creature) -> Bool = { creature in
            if selector.matches(creature: creature) {
                if currentIndex >= selector.startingIndex {
                    result.append(.creature(creature))
                    guard result.count < selector.count else { return false } // finished
                }
                currentIndex += 1
            }
            return true // need more
        }

        // Returns true if should continue matching
        let matchAndAppendRoom: (Room) -> Bool = { room in
            if selector.matches(room: room) {
                if currentIndex >= selector.startingIndex {
                    result.append(.room(room))
                    guard result.count < selector.count else { return false } // finished
                }
                currentIndex += 1
            }
            return true // need more
        }

        // Item | Equipment | Equipment or World
        
        // Item | Inventory | Inventory or World
        
        // Creature | Room && !Self | Room or World
        if entityTypes.contains(.creature), locations.contains(.room) || locations.contains(.world) {
            if let room = room {
                for creature in room.creatures {
                    guard self != creature else { continue }
         
                    guard matchAndAppendCreature(creature) else { return result }
                }
            }
        }
        
        // Item | Room | Room or World
        
        // Creature | Instance && !Room && !Self | World
        if entityTypes.contains(.creature), locations.contains(.world) {
            if let areaInstance = room?.areaInstance {
                for (_, currentRoom) in areaInstance.roomsById {
                    guard currentRoom != room else { continue }
                    
                    for creature in currentRoom.creatures {
                        guard self != creature else { continue }
                        
                        guard matchAndAppendCreature(creature) else { return result }
                    }
                }
            }
        }
        
        // Item | Instance && !Room | World
        
        // Room | Instance | World
        if entityTypes.contains(.room), locations.contains(.world) {
            if let areaInstance = room?.areaInstance {
                for (_, currentRoom) in areaInstance.roomsById {
                    guard matchAndAppendRoom(currentRoom) else { return result }
                }
            }
        }
        
        // Creature | World && !Instance && !Room && !Self | World
        if entityTypes.contains(.creature), locations.contains(.world) {
            for creature in world.creatures {
                // If self isn't in any instance, then iterate everybody in world.
                // Otherwise, exclude creatures in self's instance from search because they were accounted for already.
                guard room?.areaInstance == nil || creature.room?.areaInstance != room?.areaInstance else { continue }
                // Instance is taken from room, so we've already excluded room
                // This one is probably not neccessary as well, but to be safe:
                guard self != creature else { continue }

                guard matchAndAppendCreature(creature) else { return result }
            }
        }
        
        // Item | World && !Room && !Inventory && !Equipment | World
        
        // Room | World && !Instance | World
        if entityTypes.contains(.room), locations.contains(.world) {
            for (_, currentArea) in world.areasById {
                for (_, currentInstance) in currentArea.instancesByIndex {
                    guard currentInstance != room?.areaInstance else { return result }
                    
                    for (_, currentRoom) in currentInstance.roomsById {
                        guard matchAndAppendRoom(currentRoom) else { return result }
                    }
                }
            }
        }
        
        return result
    }
}
