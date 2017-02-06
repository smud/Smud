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
    
    public struct What: OptionSet {
        public let rawValue: Int

        static let character = What(rawValue: 1 << 0)
        static let item = What(rawValue: 1 << 1)

        public init(rawValue: Int) { self.rawValue = rawValue }
    }
    
    public struct Where: OptionSet {
        public let rawValue: Int
        
        static let world = Where(rawValue: 1 << 0)
        static let room = Where(rawValue: 1 << 1)
        static let inventory = Where(rawValue: 1 << 2)
        static let equipment = Where(rawValue: 1 << 3)

        public init(rawValue: Int) { self.rawValue = rawValue }
    }
    
    public func find(byName name: String, what: What, where: Where, index: Int = 1, count: Int = 1) -> [FindResult] {
        
        guard !name.isEmpty else { return [] }
        
        // Creature: Self
        if name.isEqual(toOneOf: "i", "me", "self", caseInsensitive: true) {
                return [.creature(self)]
        }
        
        var result: [FindResult] = []

        // Item: Equipment | World
        
        // Item: Inventory | World
        
        // Creature: Room | World
        if let room = room {
            for creature in room.creatures {
                guard creature.hasKeyword(withPrefix: name) else { continue }
                result.append(.creature(creature))
            }
        }
        
        // Item: Room | World
        
        // Creature: World
        for creature in world.creatures where creature.room != room {
            guard creature.hasKeyword(withPrefix: name) else { continue }
            result.append(.creature(creature))
        }
        
        // Item: World
        
        return result
    }
}
