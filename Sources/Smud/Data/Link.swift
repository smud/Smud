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
import ScannerUtils

public class Link: CustomStringConvertible {
    public var areaId: String?
    public var entityId: String
    public var instanceIndex: Int?
    
    public var isQualified: Bool { return areaId != nil || instanceIndex != nil }
    
    public convenience init?(scanFrom scanner: Scanner) {
        let originalLocation = scanner.scanLocation
        guard let text = scanner.scanUpTo("") else {
            return nil
        }
        guard text.hasPrefix("#") else {
            scanner.scanLocation = originalLocation
            return nil
        }
        self.init(text)
    }
    
    public init?(_ text: String) {
        guard text.hasPrefix("#") else { return nil }
        
        let elements = text.droppingPrefix().components(separatedBy: ":")
        guard 1...2 ~= elements.count else { return nil }
        
        if elements.count == 2 {
            guard let instanceIndex = Int(elements[1]) else { return nil }
            self.instanceIndex = instanceIndex
        }
        
        var path = elements[0].components(separatedBy: ".")
        guard 1...2 ~= path.count else { return nil }
        
        guard let entityId = path.popLast(), !entityId.isEmpty else { return nil }
        self.entityId = entityId
        
        if let areaId = path.popLast() {
            if areaId.isEmpty { return nil }
            self.areaId = areaId
        }
    }

    public init(room: Room) {
        self.areaId = room.areaInstance.area.id
        self.entityId = room.id
        self.instanceIndex = room.areaInstance.index // FIXME: Link shouldn't refer to a specific instance
    }
    
    public var description: String {
        var result = "#"
        if let areaId = areaId {
            result += "\(areaId)."
        }
        result += entityId
        if let instanceIndex = self.instanceIndex {
            result += ":\(instanceIndex)"
        }
        return result
    }
    
    public func matches(creature: Creature) -> Bool {
        guard let mobile = creature as? Mobile else { return false }
        let homeInstance = mobile.home?.areaInstance

        guard areaId == nil || areaId! == homeInstance?.area.id else {
            return false
        }

        guard instanceIndex == nil || instanceIndex! == homeInstance?.index else {
            return false
        }

        guard let id = mobile.prototype.value(named: "mobile")?.string else {
            return false
        }
        
        if entityId.isEqual(to: id, caseInsensitive: true) {
            return true
        }
        
        return false
    }

    public func matches(room: Room) -> Bool {
        let homeInstance = room.areaInstance
        
        guard areaId == nil || areaId! == homeInstance.area.id else {
            return false
        }
        
        guard instanceIndex == nil || instanceIndex! == homeInstance.index else {
            return false
        }
        
        guard let id = room.prototype.value(named: "room")?.string else {
            return false
        }
        
        if entityId.isEqual(to: id, caseInsensitive: true) {
            return true
        }
        
        return false
    }
}
