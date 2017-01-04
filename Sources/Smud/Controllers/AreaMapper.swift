//
// AreaMapper.swift
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

class AreaMapper {
    struct RoomAndDirection: Hashable {
        let room: Room
        let direction: Direction
        
        static func ==(lhs: RoomAndDirection, rhs: RoomAndDirection) -> Bool {
            return lhs.room == rhs.room &&
                lhs.direction == rhs.direction
        }
        
        public var hashValue: Int {
            let prime = 92821
            var result = prime &+ room.hashValue
            result = prime &* result &+ direction.hashValue
            return result
        }
    }
    
    func buildAreaMap(startingRoom: Room) -> AreaMap {
        let areaMap = AreaMap(startingRoom: startingRoom)
        
        var queue: [Room] = [startingRoom]
        
        var visited = Set<RoomAndDirection>()

        repeat {
            let currentRoom = queue.removeFirst()

            for exit in currentRoom.exits {
                let direction = exit.key
                
                let roomAndDirection = RoomAndDirection(room: currentRoom, direction: direction)
                
                guard !visited.contains(roomAndDirection) else { continue }
                
                if let nextRoom = currentRoom.resolveExit(direction: direction) {
                    
                    // No cross area mapping
                    guard nextRoom.areaInstance == startingRoom.areaInstance else { continue }
                    
                    let result = areaMap.dig(toRoom: nextRoom, fromRoom: currentRoom, direction: direction)
                    if result == .didAddRoom {
                        queue.append(nextRoom)
                    }
                    visited.insert(roomAndDirection)
                }
            }
        } while !queue.isEmpty
        
        return areaMap
    }
}
