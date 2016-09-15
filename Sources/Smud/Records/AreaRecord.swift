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
import GRDB

class AreaRecord: Record, ModifiablePersistable {
//    typealias RoomsByTag = [String: Room]
    
    var areaId: Int64?
    var primaryTag: String
    //var extraTags: Set<String> = []
    var name = ""
    
    override class var databaseTableName: String { return "areas" }

    required init(row: Row) {
        areaId = row.value(named: "area_id")
        primaryTag = row.value(named: "primary_tag")
        name = row.value(named: "name")
        super.init(row: row)
    }

    required init(entity: Area) {
        areaId = entity.areaId
        primaryTag = entity.primaryTag
        name = entity.name
        super.init()
    }

    func createEntity() -> Area {
        let area = Area(primaryTag: primaryTag)
        area.areaId = areaId
        area.name = name
        return area
    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["area_id": areaId,
                "primary_tag": primaryTag,
                "name": name]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        guard let area = Area.with(primaryTag: primaryTag) else {
            fatalError("Error while updating area id")
        }
        areaId = rowID
        area.areaId = rowID
    }
}
