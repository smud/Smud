//
// ModifiablePersistable.swift
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
//protocol ModifiablePersistable: GRDB.Persistable, GRDB.RowConvertible {
//    associatedtype Entity: Modifiable
//    
//    init(entity: Entity)
//    var entity: Entity { get }
//
//    static func saveModifiedEntitiesAsync(completion: @escaping (_ count: Int)->())
//    static func loadAllEntitiesSync() -> [Entity]
//}
//
//extension ModifiablePersistable {
//    static func saveModifiedEntitiesAsync(completion: @escaping (_ count: Int)->() = {_ in}) {
//        guard !Entity.modifiedEntities.isEmpty else {
//            completion(0)
//            return
//        }
//        
//        let records = Entity.modifiedEntities.map {
//            return Self(entity: $0)
//        }
//        Entity.modifiedEntities.removeAll(keepingCapacity: true)
//        
//        DB.serialSaveQueue.async {
//            do {
//                try DB.queue.inTransaction { db in
//                    for record in records {
//                        if record.entity.deleted {
//                            try record.delete(db)
//                        } else {
//                            try record.save(db)
//                        }
//                    }
//                    return .commit
//                }
//            } catch {
//                fatalError("While saving records to database: \(error)")
//            }
//            DispatchQueue.main.async {
//                completion(records.count)
//            }
//        }
//    }
//    
//    static func loadAllEntitiesSync() -> [Entity] {
//        let records = DB.queue.inDatabase { db in
//            Self.fetchAll(db)
//        }
//        var result = [Entity]()
//        result.reserveCapacity(records.count)
//        for record in records {
//            result.append(record.entity)
//        }
//        return result
//    }
//    
//}
