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

class AreaRecord: Record {
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

    init(primaryTag: String) {
        self.primaryTag = primaryTag
        super.init()
    }

//    func save() throws {
//        try DB.queue.inDatabase { db in try save(db) }
//    }
    
//    func delete() throws -> Bool {
//        return try DB.queue.inDatabase { db in try delete(db) }
//    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["area_id": areaId,
                "primary_tag": primaryTag,
                "name": name]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        areaId = rowID
    }
}
