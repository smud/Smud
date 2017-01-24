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
    var xRange = 0 ..< 0
    var yRange = 0 ..< 0
    var planeRange = 0 ..< 0
    
    init(startingRoom: Room? = nil) {
        if let startingRoom = startingRoom {
            let toPosition = AreaMapPosition(0, 0, 0)
            add(room: startingRoom, position: toPosition)
        }
    }
    
    func dig(toRoom: Room, fromRoom: Room, direction: Direction) -> DigResult {
        guard positionsByRoom[toRoom] == nil else { return .toRoomAlreadyExists }
        guard let fromPosition = positionsByRoom[fromRoom] else { return .fromRoomDoesNotExist }
        switch direction {
        case .north:
            let toPosition = fromPosition.adjustedBy(y: -1)
            if mapElementsByPosition[toPosition] != nil {
                shift(northOf: fromPosition.y, distance: 1)
            }
            add(room: toRoom, position: toPosition)
            return .didAddRoom
        case .south:
            let toPosition = fromPosition.adjustedBy(y: 1)
            if mapElementsByPosition[toPosition] != nil {
                shift(southOf: fromPosition.y, distance: 1)
            }
            add(room: toRoom, position: toPosition)
            return .didAddRoom
        case .west:
            let toPosition = fromPosition.adjustedBy(x: -1)
            if mapElementsByPosition[toPosition] != nil {
                shift(westOf: fromPosition.x, distance: 1)
            }
            add(room: toRoom, position: toPosition)
            return .didAddRoom
        case .east:
            let toPosition = fromPosition.adjustedBy(x: 1)
            if mapElementsByPosition[toPosition] != nil {
                shift(eastOf: fromPosition.x, distance: 1)
            }
            add(room: toRoom, position: toPosition)
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
    
    func add(room: Room, position: AreaMapPosition) {
        mapElementsByPosition[position] = .room(room)
        positionsByRoom[room] = position
        
        xRange = min(position.x, xRange.lowerBound) ..< max(position.x + 1, xRange.upperBound)
        yRange = min(position.y, yRange.lowerBound) ..< max(position.y + 1, yRange.upperBound)
        planeRange = min(position.plane, planeRange.lowerBound) ..< max(position.plane + 1, planeRange.upperBound)
    }
    
    func shift(northOf y: Int, distance: Int) {
        yRange = yRange.lowerBound - distance ..< yRange.upperBound
        
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
        yRange = yRange.lowerBound ..< yRange.upperBound + distance

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
        xRange = xRange.lowerBound - distance ..< xRange.upperBound

        let oldMapElementsByPosition = mapElementsByPosition
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.x < x else { continue }
            mapElementsByPosition.removeValue(forKey: oldPosition)
            
            let newPosition = oldPosition.adjustedBy(x: -distance)
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
        xRange = xRange.lowerBound ..< xRange.upperBound + distance

        let oldMapElementsByPosition = mapElementsByPosition
        
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.x > x else { continue }
            mapElementsByPosition.removeValue(forKey: oldPosition)
            
            let newPosition = oldPosition.adjustedBy(x: distance)
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
    
    func debugPrint() {
        let minX = xRange.lowerBound
        let minY = yRange.lowerBound
        //let minPlane = planeRange.lowerBound

        let elementWidth = 14

        let fillLine = [String](repeating: " ".padding(toLength: elementWidth, withPad: " ", startingAt: 0), count: xRange.count)
        var grid = [[String]](repeating: fillLine, count: yRange.count)
        
        for (position, element) in mapElementsByPosition {
            guard position.plane == 0 else { continue }
            let atX = position.x - minX
            let atY = position.y - minY
            switch element {
            case .room(let room):
                grid[atY][atX] = room.id.padding(toLength: elementWidth, withPad: " ", startingAt: 0)
            case .passage(let orientation):
                switch orientation {
                case .northSouth:
                    grid[atY][atX] = "|".padding(toLength: elementWidth, withPad: " ", startingAt: 0)
                case .westEast:
                    grid[atY][atX] = "-".padding(toLength: elementWidth, withPad: " ", startingAt: 0)
                case .upDown:
                    grid[atY][atX] = "x".padding(toLength: elementWidth, withPad: " ", startingAt: 0)
                }
            }
        }
        
        for row in grid {
            print(row)
        }
    }
}
