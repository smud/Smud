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

    typealias RenderedMap = [/* Plane */ Int: /* Plane map */ [[Character]]]

    var mapElementsByPosition = [AreaMapPosition: AreaMapElement]()
    var positionsByRoom = [Room: AreaMapPosition]()

    var elementsCount: Int { return mapElementsByPosition.count }
    var roomsCount: Int { return positionsByRoom.count }
    var range = AreaMapRange(AreaMapPosition(0, 0, 0))
    var rangesByPlane = [Int: AreaMapRange]()

    var renderedMap = RenderedMap()
    var renderedRoomCentersByRoom = [Room: AreaMapPosition]() // AreaMapPosition is used here only for convenience, its x and y specify room center offset in characters relative to top-left corner of the rendered map

    var renderedMapRequiresRedrawing = false

    init(startingRoom: Room? = nil) {
        if let startingRoom = startingRoom {
            let toPosition = AreaMapPosition(0, 0, 0)
            add(room: startingRoom, position: toPosition)
        }
    }

    public func fragment(near room: Room, width: Int, height: Int) -> String {
        if renderedMapRequiresRedrawing {
            render()
        }

        guard let roomCenter = renderedRoomCentersByRoom[room] else { return "" }
        guard let map = renderedMap[roomCenter.plane] else { return "" }
        guard map.count > 0 && map[0].count > 0 else { return "" }

        let topLeftHalf = AreaMapPosition(width / 2, height / 2, 0)
        let topRightHalf = AreaMapPosition(width, height, 0) - topLeftHalf

        let from = upperBound(roomCenter - topLeftHalf, AreaMapPosition(0, 0, roomCenter.plane))
        let to = lowerBound(roomCenter + topRightHalf, AreaMapPosition(map[0].count, map.count, roomCenter.plane))

        var fragment = String()
        fragment.reserveCapacity((to.x - from.x + /* for newline */ 1) * (to.y - from.y))

        for y in from.y..<to.y {
            fragment += String(map[y][from.x..<to.x])
            fragment += "\n"
        }

        return fragment
    }

    func dig(toRoom: Room, fromRoom: Room, direction: Direction) -> DigResult {
        guard positionsByRoom[toRoom] == nil else { return .toRoomAlreadyExists }
        guard let fromPosition = positionsByRoom[fromRoom] else { return .fromRoomDoesNotExist }

        let toPosition = fromPosition + AreaMapPosition(direction,  1)
        if mapElementsByPosition[toPosition] != nil {
            shift(from: fromPosition, direction: direction, distance: 1)
        }

        add(room: toRoom, position: toPosition)

        renderedMapRequiresRedrawing = true

        return .didAddRoom
    }

    func add(room: Room, position: AreaMapPosition) {
        mapElementsByPosition[position] = .room(room)
        positionsByRoom[room] = position

        range.expand(with: position)

        if let planeRange = rangesByPlane[position.plane] {
            rangesByPlane[position.plane] = planeRange.expanded(with: position)
        } else {
            rangesByPlane[position.plane] = AreaMapRange(position)
        }
    }

    func shift(from: AreaMapPosition, direction: Direction, distance: Int) {
        let axis = AreaMapPosition.Axis(direction)
        let shift = AreaMapPosition(direction, distance)

        range.unite(with: range.shifted(by: shift))
        for (plane, planeRange) in rangesByPlane {
            rangesByPlane[plane] = planeRange.united(with: planeRange.shifted(by: shift))
        }

        let oldMapElementsByPosition = mapElementsByPosition
        mapElementsByPosition.removeAll()

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

    func render() {
        renderedMapRequiresRedrawing = false

        renderedMap.removeAll()

        let fillCharacter: Character = " "
        let roomWidth = 3
        let roomHeight = 1
        let roomSpacingWidth = 1
        let roomSpacingHeight = 1

        for (plane, range) in rangesByPlane {
            let width = (roomWidth + roomSpacingWidth) * (range.to.x - range.from.x + 1)
            let height = (roomHeight + roomSpacingHeight) * (range.to.y - range.from.y + 1)
            renderedMap[plane] = [[Character]](repeating: [Character](repeating: fillCharacter, count: width), count: height)
        }

        for (position, element) in mapElementsByPosition {
            let plane = position.plane
            guard renderedMap[plane] != nil else { continue }
            guard let range = rangesByPlane[plane] else { continue }

            let x = (roomWidth + roomSpacingWidth) * (position.x - range.from.x)
            let y = (roomHeight + roomSpacingHeight) * (position.y - range.from.y)

            switch element {
            case .room(let room):
                renderedRoomCentersByRoom[room] = AreaMapPosition(x + roomWidth / 2, y, plane)
                renderedMap[plane]![y].replaceSubrange(x..<(x + roomWidth), with: "[ ]".characters)
                if room.exits[.east] != nil {
                    renderedMap[plane]![y][x + roomWidth] = "-"
                }
                if room.exits[.south] != nil {
                    renderedMap[plane]![y + roomHeight].replaceSubrange(x..<(x + roomWidth), with: " | ".characters)
                }
                if room.exits[.up] != nil && room.exits[.down] != nil {
                    renderedMap[plane]![y][x + roomWidth / 2] = "*"
                } else if room.exits[.up] != nil {
                    renderedMap[plane]![y][x + roomWidth / 2] = "^"
                } else if room.exits[.down] != nil {
                    renderedMap[plane]![y][x + roomWidth / 2] = "v"
                }
            case .passage(let axis):
                switch axis {
                case .x:
                    renderedMap[plane]![y].replaceSubrange(x..<(x + roomWidth), with: "---".characters)
                    renderedMap[plane]![y][x + roomWidth] = "-"
                case .y:
                    renderedMap[plane]![y].replaceSubrange(x..<(x + roomWidth), with: " | ".characters)
                    renderedMap[plane]![y + roomHeight].replaceSubrange(x..<(x + roomWidth), with: " | ".characters)
                case .plane:
                    renderedMap[plane]![y].replaceSubrange(x..<(x + roomWidth), with: " * ".characters)
                }
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
