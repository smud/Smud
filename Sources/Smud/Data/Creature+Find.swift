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
    }
    
    public struct SearchEntityTypes: OptionSet {
        public let rawValue: Int

        public static let creature = SearchEntityTypes(rawValue: 1 << 0)
        public static let item = SearchEntityTypes(rawValue: 1 << 1)

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
    
    public func find(selector: EntitySelector, entityTypes: SearchEntityTypes, locations: SearchLocations) -> [FindResult] {
        
        //guard !name.isEmpty else { return [] }
        
        // Creature: Self in Room | World
        if case .pattern(let pattern) = selector,
            pattern.startingIndex == 1,
            pattern.count == 1,
            let keyword = pattern.keywords.first,
            keyword.isEqual(toOneOf: ["i", "me", "self"], caseInsensitive: true) {
                return [.creature(self)]
        }
        
        var result: [FindResult] = []
        
        var startingIndex: Int
        var requiredCount: Int
        if case .pattern(let pattern) = selector {
            guard pattern.startingIndex > 0 && pattern.count > 0 else { return result }
            startingIndex = pattern.startingIndex
            requiredCount = pattern.count
        } else {
            startingIndex = 1
            requiredCount = 1
        }

        var currentIndex = 1

        // Item: Equipment | World
        
        // Item: Inventory | World
        
        // Creature: Room | World
        if let room = room {
            for creature in room.creatures {
                guard self != creature else { continue }
                guard selector.matches(creature: creature) else { continue }
                if currentIndex >= startingIndex {
                    result.append(.creature(creature))
                    guard result.count < requiredCount else { return result }
                }
                currentIndex += 1
            }
        }
        
        // Item: Room | World
        
        // Creature: World
        for creature in world.creatures {
            guard self != creature else { continue }
            guard creature.room != room else { continue }
            guard selector.matches(creature: creature) else { continue }
            result.append(.creature(creature))
        }
        
        // Item: World
        
        return result
    }
}
