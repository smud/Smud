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

class RoomTemplate: Record {
    var roomTemplateId: Int64?
    var primaryTag: String
    var areaId: Int64
    var properties = [String: String]()
    var propertiesData: Data {
        get { return NSKeyedArchiver.archivedData(withRootObject: properties) }
        set { properties = NSKeyedUnarchiver.unarchiveObject(with: newValue) as! [String: String] }
    }

    override class var databaseTableName: String { return "room_templates" }

    required init(row: Row) {
        roomTemplateId = row.value(named: "room_template_id")
        primaryTag = row.value(named: "primary_tag")
        areaId = row.value(named: "area_id")
        super.init(row: row)
        propertiesData = row.value(named: "properties")
    }
    
    init(primaryTag: String, areaId: Int64) {
        self.primaryTag = primaryTag
        self.areaId = areaId
        super.init()
    }
    
    func save() throws {
        try DB.queue.inDatabase { db in try save(db) }
    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["room_template_id": roomTemplateId,
                "primary_tag": primaryTag,
                "area_id": areaId,
                "properties": propertiesData]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        roomTemplateId = rowID
    }
    
    func applyTo(room: Room, unsupportedProperties: inout Set<String>) {
        /*
        for field in fields {
            let v = field.value
            switch field.key {
                case "name": room.name = v
                case "description": room.description = v
                default: unsupportedProperties.insert(field.key)
            }
            
        }
        */
    }
}
