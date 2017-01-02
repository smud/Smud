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
    func buildAreaMap(fromRoom room: Room) -> AreaMap {
        let areaMap = AreaMap()

//        var queue: [Room] = [room]
//
//        repeat {
//            let currentRoom = queue.removeFirst()
//            areaMap.put(room: currentRoom, atPosition: position)
//            
//            if let nextRoom = currentRoom.resolveExit(direction: .north) {
//                let nextPosition = areaMap.position(of: currentRoom).adjustedBy(y: -1)
//                if areaMap.isCellEmpty(position: nextPosition) {
//                    areaMap.put(room: nextRoom, atPosition: nextPosition)
//                } else {
//                    
//                }
//
//            }
//        } while !queue.isEmpty
        
        return areaMap
    }
}
