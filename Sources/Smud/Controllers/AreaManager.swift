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
    static var areas = [String: Area]()
    
    static func loadAreas() throws {
        let array = DB.queue.inDatabase { db in Area.fetchAll(db) }
        for area in array {
            areas[area.primaryTag] = area
        }
    }
    
    static func areaExists(withPrimaryTag tag: String) -> Bool {
        return areas[tag] != nil
    }
    
    static func createArea(withPrimaryTag tag: String, name: String) throws -> Area {
        guard !areaExists(withPrimaryTag: tag) else {
            throw AreaManagerError.alreadyExists(tag: tag)
        }
        
        let area = Area(primaryTag: tag)
        area.name = name
        try area.save()

        areas[tag] = area
        return area
    }
    
    @discardableResult
    static func deleteArea(withPrimaryTag tag: String) throws -> Area {
        guard let area = areas[tag] else {
            throw AreaManagerError.doesNotExist(tag: tag)
        }
        
        if !(try area.delete()) {
            throw AreaManagerError.deleteError(tag: tag)
        }
        
        areas.removeValue(forKey: tag)
        return area
    }
    
    static func renameArea(oldTag: String, newTag: String) throws {
        guard newTag != oldTag else { return }
        
        guard let area = areas[oldTag] else {
            throw AreaManagerError.doesNotExist(tag: oldTag)
        }

        guard !areaExists(withPrimaryTag: newTag) else {
            throw AreaManagerError.alreadyExists(tag: newTag)
        }

        area.primaryTag = newTag
        try area.save()
        
        areas.removeValue(forKey: oldTag)
        areas[newTag] = area
    }
}
