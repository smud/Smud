//
// AreaMap.swift
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

public class AreaMap {
    enum DigResult {
        case fromRoomDoesNotExist
        case toRoomAlreadyExists
        case didAddRoom
        case didNothing
    }
    
    var mapElementsByPosition = [AreaMapPosition: AreaMapElement]()
    var positionsByRoom = [Room: AreaMapPosition]()
    
    var elementsCount: Int { return mapElementsByPosition.count }
    var roomsCount: Int { return positionsByRoom.count }
    
    init(startingRoom: Room? = nil) {
        if let startingRoom = startingRoom {
            positionsByRoom[startingRoom] = AreaMapPosition()
        }
    }
    
    func dig(toRoom: Room, fromRoom: Room, direction: Direction) -> DigResult {
        guard let fromPosition = positionsByRoom[fromRoom] else { return .fromRoomDoesNotExist }
        switch direction {
        case .north:
            let toPosition = fromPosition.adjustedBy(y: -1)
            if let element = mapElementsByPosition[toPosition] {
                guard case .room(let room) = element, room == toRoom else { return .toRoomAlreadyExists }
                shift(northOf: fromPosition.y, distance: 1)
            }
            mapElementsByPosition[toPosition] = .room(toRoom)
            positionsByRoom[toRoom] = toPosition
            return .didAddRoom
        case .south:
            let toPosition = fromPosition.adjustedBy(y: 1)
            if let element = mapElementsByPosition[toPosition] {
                guard case .room(let room) = element, room == toRoom else { return .toRoomAlreadyExists }
                shift(southOf: fromPosition.y, distance: 1)
            }
            mapElementsByPosition[toPosition] = .room(toRoom)
            positionsByRoom[toRoom] = toPosition
            return .didAddRoom
        case .west:
            let toPosition = fromPosition.adjustedBy(x: -1)
            if let element = mapElementsByPosition[toPosition] {
                guard case .room(let room) = element, room == toRoom else { return .toRoomAlreadyExists }
                shift(westOf: fromPosition.x, distance: 1)
            }
            mapElementsByPosition[toPosition] = .room(toRoom)
            positionsByRoom[toRoom] = toPosition
            return .didAddRoom
        case .east:
            let toPosition = fromPosition.adjustedBy(x: 1)
            if let element = mapElementsByPosition[toPosition] {
                guard case .room(let room) = element, room == toRoom else { return .toRoomAlreadyExists }
                shift(eastOf: fromPosition.x, distance: 1)
            }
            mapElementsByPosition[toPosition] = .room(toRoom)
            positionsByRoom[toRoom] = toPosition
            return .didAddRoom
        case .up:
            // TODO
            break
        case .down:
            // TODO
            break
        }
        return .didNothing
    }
    
    func shift(northOf y: Int, distance: Int) {
        let oldMapElementsByPosition = mapElementsByPosition
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.y < y else { continue }
            mapElementsByPosition.removeValue(forKey: oldPosition)
            
            let newPosition = oldPosition.adjustedBy(y: -distance)
            mapElementsByPosition[newPosition] = element
            if case .room(let room) = element {
                positionsByRoom[room] = newPosition
            }
        }
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.y == y - 1 else { continue }
            if case .passage(.northSouth) = element {
                for fillY in y - distance - 1 ... y - 1 {
                    let position = AreaMapPosition(oldPosition.x, fillY, oldPosition.plane)
                    mapElementsByPosition[position] = element
                }
            }
        }
    }

    func shift(southOf y: Int, distance: Int) {
        let oldMapElementsByPosition = mapElementsByPosition
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.y > y else { continue }
            mapElementsByPosition.removeValue(forKey: oldPosition)
            
            let newPosition = oldPosition.adjustedBy(y: distance)
            mapElementsByPosition[newPosition] = element
            if case .room(let room) = element {
                positionsByRoom[room] = newPosition
            }
        }
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.y == y + 1 else { continue }
            if case .passage(.northSouth) = element {
                for fillY in y + 1 ... y + distance + 1 {
                    let position = AreaMapPosition(oldPosition.x, fillY, oldPosition.plane)
                    mapElementsByPosition[position] = element
                }
            }
        }
    }

    func shift(westOf x: Int, distance: Int) {
        let oldMapElementsByPosition = mapElementsByPosition
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.x < x else { continue }
            mapElementsByPosition.removeValue(forKey: oldPosition)
            
            let newPosition = oldPosition.adjustedBy(y: -distance)
            mapElementsByPosition[newPosition] = element
            if case .room(let room) = element {
                positionsByRoom[room] = newPosition
            }
        }
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.x == x - 1 else { continue }
            if case .passage(.westEast) = element {
                for fillX in x - distance - 1 ... x - 1 {
                    let position = AreaMapPosition(fillX, oldPosition.y, oldPosition.plane)
                    mapElementsByPosition[position] = element
                }
            }
        }
    }

    func shift(eastOf x: Int, distance: Int) {
        let oldMapElementsByPosition = mapElementsByPosition
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.x > x else { continue }
            mapElementsByPosition.removeValue(forKey: oldPosition)
            
            let newPosition = oldPosition.adjustedBy(y: distance)
            mapElementsByPosition[newPosition] = element
            if case .room(let room) = element {
                positionsByRoom[room] = newPosition
            }
        }
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.x == x + 1 else { continue }
            if case .passage(.westEast) = element {
                for fillX in x + 1 ... x + distance + 1 {
                    let position = AreaMapPosition(fillX, oldPosition.y, oldPosition.plane)
                    mapElementsByPosition[position] = element
                }
            }
        }
    }
}
