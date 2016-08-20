//
// AreaManager.swift
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

class AreaManager {
    typealias T = AreaManager
    
    /// All areas except deleted ones
    static private var loadedAreas = [String: Area]()
    
    /// Temporarily store deleted areas until they are deleted from database
    static private var areasToDelete = [String: Area]()

    static private var areasToSave = [String: Area]()

    static func area(withPrimaryTag tag: String) throws -> Area {
        if let area = loadedAreas[tag] {
            return area
        }
        let area = DB.queue.inDatabase { db in
            Area.fetchOne(db, "SELECT * FROM areas WHERE primary_tag = ?",
                arguments: [tag])
        }
        if let area = area {
            loadedAreas[area.primaryTag] = area
            return area
        }
        throw AreaManagerError.doesNotExist(tag)
    }
    
    static func areaExists(withPrimaryTag tag: String) throws -> Bool {
        do {
            let _ = try area(withPrimaryTag: tag)
        } catch AreaManagerError.doesNotExist {
            return false
        }
        return true
    }
    
    static func createArea(withPrimaryTag tag: String) throws -> Area {
        guard !(try areaExists(withPrimaryTag: tag)) else {
            throw AreaManagerError.alreadyExists(tag)
        }
        
        let area = Area(primaryTag: tag)
        loadedAreas[tag] = area
        areasToSave[tag] = area
        
        if areasToDelete[tag] != nil {
            areasToDelete.removeValue(forKey: tag)
        }
        
        return area
    }
    
    @discardableResult
    static func deleteArea(withPrimaryTag tag: String) throws -> Area {
        let area = try self.area(withPrimaryTag: tag)
        loadedAreas.removeValue(forKey: tag)
        areasToDelete[tag] = area
        return area
    }
    
    static func renameArea(oldTag: String, newTag: String) throws {
        
        let area = try self.area(withPrimaryTag: oldTag)
        
        guard !(try areaExists(withPrimaryTag: newTag)) else {
            throw AreaManagerError.alreadyExists(newTag)
        }

        area.primaryTag = newTag
        loadedAreas.removeValue(forKey: oldTag)
        areasToSave.removeValue(forKey: oldTag)
        loadedAreas[newTag] = area
        areasToSave[newTag] = area
    }
    
    static func saveArea(area: Area) {
        areasToSave[area.primaryTag] = area
    }
    
    static func flush() throws {
        try DB.queue.inTransaction { db in
            for area in areasToDelete {
                try db.execute("DELETE FROM areas WHERE primary_tag = ?", arguments: [area.value.primaryTag])
            }
            for area in areasToSave {
                try area.value.save(db)
            }
            return .commit
        }
        areasToDelete.removeAll(keepingCapacity: true)
        areasToSave.removeAll(keepingCapacity: true)
    }
}
