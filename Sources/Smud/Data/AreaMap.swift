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
    var range = (from: AreaMapPosition(0, 0, 0), to: AreaMapPosition(0, 0, 0))

    init(startingRoom: Room? = nil) {
        if let startingRoom = startingRoom {
            let toPosition = AreaMapPosition(0, 0, 0)
            add(room: startingRoom, position: toPosition)
        }
    }

    func dig(toRoom: Room, fromRoom: Room, direction: Direction) -> DigResult {
        guard positionsByRoom[toRoom] == nil else { return .toRoomAlreadyExists }
        guard let fromPosition = positionsByRoom[fromRoom] else { return .fromRoomDoesNotExist }

        let toPosition = fromPosition + AreaMapPosition(direction,  1)
        if mapElementsByPosition[toPosition] != nil {
            shift(from: fromPosition, direction: direction, distance: 1)
        }

        add(room: toRoom, position: toPosition)

        return .didAddRoom
    }

    func add(room: Room, position: AreaMapPosition) {
        mapElementsByPosition[position] = .room(room)
        positionsByRoom[room] = position

        range.from = lowerBound(range.from, position)
        range.to = upperBound(range.to, position)
    }

    func shift(from: AreaMapPosition, direction: Direction, distance: Int) {
        let axis = AreaMapPosition.Axis(direction)
        let shift = AreaMapPosition(direction, distance)

        range.from = lowerBound(range.from, range.from + shift)
        range.to = upperBound(range.to, range.to + shift)

        let oldMapElementsByPosition = mapElementsByPosition

        for (oldPosition, element) in oldMapElementsByPosition {
            guard (oldPosition - from).direction(axis: axis) == direction else {
                mapElementsByPosition[oldPosition] = element
                continue
            }

            let newPosition = oldPosition + shift
            mapElementsByPosition[newPosition] = element
            if case .room(let room) = element {
                positionsByRoom[room] = newPosition
            }
        }


        let fillElement = AreaMapElement.passage(axis)
        let fillFrom = (from + AreaMapPosition(direction, 1)).get(axis: axis)
        let fillTo = (from + AreaMapPosition(direction, distance)).get(axis: axis)
        let fillRange = min(fillFrom, fillTo)...max(fillFrom, fillTo)
        for (oldPosition, element) in oldMapElementsByPosition {
            guard oldPosition.get(axis: axis) == from.get(axis: axis) else {
                continue
            }

            switch element {
            case .room(let room) where room.exits[direction] != nil: fallthrough
            case .passage(axis):
                for fillCoordinate in fillRange {
                    var position = oldPosition
                    position.set(axis: axis, value: fillCoordinate)
                    mapElementsByPosition[position] = fillElement
                }
            default:
                break
            }
        }

    }

    func debugPrint() {
        let minX = range.from.x
        let minY = range.from.y
        //let minPlane = planeRange.lowerBound

        let elementWidth = 14

        let fillLine = [String](repeating: " ".padding(toLength: elementWidth, withPad: " ", startingAt: 0), count: range.to.x - range.from.x + 1)
        var grid = [[String]](repeating: fillLine, count: range.to.y - range.from.y + 1)

        for (position, element) in mapElementsByPosition {
            guard position.plane == 0 else { continue }
            let atX = position.x - minX
            let atY = position.y - minY
            switch element {
            case .room(let room):
                grid[atY][atX] = room.id.padding(toLength: elementWidth, withPad: " ", startingAt: 0)
            case .passage(let axis):
                switch axis {
                case .y:
                    grid[atY][atX] = "|".padding(toLength: elementWidth, withPad: " ", startingAt: 0)
                case .x:
                    grid[atY][atX] = "-".padding(toLength: elementWidth, withPad: " ", startingAt: 0)
                case .plane:
                    grid[atY][atX] = "x".padding(toLength: elementWidth, withPad: " ", startingAt: 0)
                }
            }
        }

        for row in grid {
            print(row)
        }
    }
}
