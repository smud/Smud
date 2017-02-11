//
// World.swift
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

public class World {
    public let smud: Smud
    public var areasById = [String: Area]()
    public var creatures = [Creature]()
    
    public init(smud: Smud) {
        self.smud = smud
    }

    public func resolveRoom(link: Link, defaultInstance: AreaInstance? = nil) -> Room? {
        let roomId = link.entity

        if link.parent == nil && link.instance == nil {
            guard let defaultInstance = defaultInstance else { return nil }
            guard let room = defaultInstance.roomsById[roomId] else { return nil }
            return room
        }

        guard let areaId = link.parent, let instanceIndex = link.instance else { return nil }
        guard let area = areasById[areaId] else { return nil }
        guard let areaInstance = area.instancesByIndex[instanceIndex] else { return nil }
        guard let room = areaInstance.roomsById[roomId] else { return nil }

        return room
    }
}
