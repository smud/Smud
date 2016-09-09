//
// RoomManager.swift
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

//class RoomManager {
//    typealias T = RoomManager
//    typealias Templates = [String: RoomTemplate]
//    static var areaTemplates = [String: Templates]()
//    
//    static func loadRoomTemplates(area: Area) throws {
//        let array = DB.queue.inDatabase { db in
//            RoomTemplate.fetchAll(db, "SELECT * FROM room_templates WHERE area_id = ?", arguments: [area.areaId]) }
//        var templates = Templates()
//        for roomTemplate in array {
//             templates[roomTemplate.primaryTag] = roomTemplate
//        }
//        areaTemplates[area.primaryTag] = templates
//    }
//    
//    static func roomTemplate(tag: Tag, player: Player) -> RoomTemplate? {
//        guard let areaTag = tag.area ?? player.area?.primaryTag else { return nil }
//        let templates = areaTemplates[areaTag]
//        return templates?[tag.object]
//    }
//    
//    static func createRoomTemplate(tag: Tag, player: Player) throws -> RoomTemplate {
//        guard nil == T.roomTemplate(tag: tag, player: player) else {
//            throw RoomManagerError.templateAlreadyExists(tag: tag)
//        }
//
//        guard let areaTag = tag.area ?? player.area?.primaryTag else {
//            throw RoomManagerError.areaNotSpecified
//        }
//        guard let areaId = AreaManager.areas[areaTag]?.areaId else {
//            throw RoomManagerError.areaDoesNotExist(tag: tag)
//        }
//
//        let roomTemplate = RoomTemplate(primaryTag: tag.object, areaId: areaId)
//        try roomTemplate.save()
//
//        if nil == areaTemplates[areaTag] {
//            areaTemplates[areaTag] = Templates()
//        }
//        areaTemplates[areaTag]?[tag.object] = roomTemplate
//        
//        return roomTemplate
//    }
//}
