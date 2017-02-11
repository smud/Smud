//
// Link.swift
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

public class Link: CustomStringConvertible {
    public var parent: String?
    public var entity: String
    public var instance: Int?
    
    public var isQualified: Bool { return parent != nil || instance != nil }
    
    public init?(_ text: String) {
        guard text.hasPrefix("#") else { return nil }
        
        let elements = text.droppingPrefix().components(separatedBy: ":")
        guard 1...2 ~= elements.count else { return nil }
        
        if elements.count == 2 {
            guard let instance = Int(elements[1]) else { return nil }
            self.instance = instance
        }
        
        var path = elements[0].components(separatedBy: ".")
        guard 1...2 ~= path.count else { return nil }
        
        guard let entity = path.popLast(), !entity.isEmpty else { return nil }
        self.entity = entity
        
        if let parent = path.popLast() {
            if parent.isEmpty { return nil }
            self.parent = parent
        }
    }

    public init(room: Room) {
        self.parent = room.areaInstance.area.id
        self.entity = room.id
        self.instance = room.areaInstance.index
    }
    
    public var description: String {
        var result = "#"
        if let parent = parent {
            result += "\(parent)."
        }
        result += entity
        if let instance = self.instance {
            result += ":\(instance)"
        }
        return result
    }
    
    public func matches(creature: Creature) -> Bool {
        let mobile = creature as? Mobile
        let homeInstance = mobile?.home?.areaInstance

        guard parent == nil || parent! == homeInstance?.area.id else {
            return false
        }

        guard instance == nil || instance! == homeInstance?.index else {
            return false
        }

        if entity.isEqual(toOneOf: creature.nameKeywords, caseInsensitive: true) {
            return true
        }
        
        return false
    }
}
