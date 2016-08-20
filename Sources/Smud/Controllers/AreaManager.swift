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
    /// All areas except deleted ones
    static var areas = [String: Area]()
    
    /// Temporarily store deleted areas until they are deleted from database
    static private var deletedAreas = [String: Area]()
    static private var areasToBeSaved = [String: Area]()

    static func createArea(withPrimaryTag tag: String) throws -> Area {
        if areas[tag] != nil {
            throw AreaManagerError.arleadyExists(tag)
        }
        let area = Area(primaryTag: tag)
        areas[tag] = area
        areasToBeSaved[tag] = area
        
        if deletedAreas[tag] != nil {
            deletedAreas.removeValue(forKey: tag)
        }
        
        return area
    }
    
    @discardableResult
    static func deleteArea(withId id: String) throws -> Area {
        guard let area = areas[id] else {
            throw AreaManagerError.doesNotExist(id)
        }
        areas.removeValue(forKey: id)
        deletedAreas[id] = area
        return area
    }
    
    static func renameArea(oldTag: String, newTag: String) throws {
        
        guard let area = areas[oldTag] else {
            throw AreaManagerError.doesNotExist(oldTag)
        }
        guard nil == areas[newTag] else {
            throw AreaManagerError.arleadyExists(newTag)
        }
        area.primaryTag = newTag
        areas.removeValue(forKey: oldTag)
        areas[newTag] = area
        areasToBeSaved[newTag] = area
    }
    
    static func saveArea(area: Area) {
        areasToBeSaved[area.primaryTag] = area
    }
    
    static func flush() throws {
        try DB.queue.inTransaction { db in
            for area in deletedAreas {
                try db.execute("DELETE FROM areas WHERE primary_tag = ?", arguments: [area.value.primaryTag])
            }
            for area in areasToBeSaved {
                try area.value.save(db)
            }
            return .commit
        }
        deletedAreas.removeAll(keepingCapacity: true)
        areasToBeSaved.removeAll(keepingCapacity: true)
    }
}
