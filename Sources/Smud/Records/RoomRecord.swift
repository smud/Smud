//
// RoomTemplate.swift
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
import GRDB

class RoomRecord: Record {
    var roomId: Int64?
    var primaryTag: String
    var areaId: Int64
    var properties: Data
//    var properties = [String: String]()
//    var propertiesData: Data {
//        get { return NSKeyedArchiver.archivedData(withRootObject: properties) }
//        set { properties = NSKeyedUnarchiver.unarchiveObject(with: newValue) as! [String: String] }
//    }

    override class var databaseTableName: String { return "rooms" }

    required init(row: Row) {
        roomId = row.value(named: "room_id")
        primaryTag = row.value(named: "primary_tag")
        areaId = row.value(named: "area_id")
        properties = row.value(named: "properties")
        super.init(row: row)
    }
    
//    init(primaryTag: String, areaId: Int64) {
//        self.primaryTag = primaryTag
//        self.areaId = areaId
//        super.init()
//    }
    
//    func save() throws {
//        try DB.queue.inDatabase { db in try save(db) }
//    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["room_id": roomId,
                "primary_tag": primaryTag,
                "area_id": areaId,
                "properties": properties]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        roomId = rowID
    }
    
//    func applyTo(room: Room, unsupportedProperties: inout Set<String>) {
//        for field in fields {
//            let v = field.value
//            switch field.key {
//                case "name": room.name = v
//                case "description": room.description = v
//                default: unsupportedProperties.insert(field.key)
//            }
//            
//        }
//    }
}
