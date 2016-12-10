//
// Area.swift
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
//import GRDB
//
//class AreaRecord: Record, ModifiablePersistable {
//    var entity: Area
//    
//    override class var databaseTableName: String { return "areas" }
//
//    required init(row: Row) {
//        entity = Area()
//        
//        super.init(row: row)
//        
//        entity.areaId = row.value(named: "area_id")
//        entity.primaryTag = row.value(named: "primary_tag")
//        entity.name = row.value(named: "name")
//        
//        //let roomTemplatesData: Data = row.value(named: "rooms")
//        //if let collection = NSKeyedUnarchiver.unarchiveObject(with: roomTemplatesData) {
//        //    entity.roomTemplates = collection as! TemplateCollection
//        //}
//    }
//
//    required init(entity: Area) {
//        self.entity = entity
//        super.init()
//    }
//    
//    override var persistentDictionary: [String: DatabaseValueConvertible?] {
//        return ["area_id": entity.areaId,
//                "primary_tag": entity.primaryTag,
//                "name": entity.name,
//                "rooms": Data(count: 1)
//                //"rooms": NSKeyedArchiver.archivedData(withRootObject: entity.roomTemplates)
//        ]
//    }
//    
//    override func didInsert(with rowID: Int64, for column: String?) {
//        Area.removeFromIndexes(area: entity)
//        entity.areaId = rowID
//        Area.addToIndexes(area: entity)
//    }
//}
