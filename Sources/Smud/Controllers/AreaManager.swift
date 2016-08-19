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
    
    /// Temporarily store deleted areas until they aren't deleted from database
    static var deletedAreas = [String: Area]()
    
    //static private var areasToBeSaved = [String: Area]()

    static func createArea(withId id: String) throws -> Area {
        if areas[id] != nil {
            throw AreaManagerError.arleadyExists(id)
        }
        let area = Area(id: id)
        areas[id] = area
        //areasToBeSaved[id] = area
        return area
    }
    
    static func deleteArea(withId id: String) throws {
        guard let area = areas[id] else {
            throw AreaManagerError.doesNotExist(id)
        }
        areas.removeValue(forKey: id)
        deletedAreas[id] = area
    }
    
    static func renameArea(oldId: String, newId: String) throws {
        
        guard let area = areas[oldId] else {
            throw AreaManagerError.doesNotExist(oldId)
        }
        guard nil == areas[newId] else {
            throw AreaManagerError.arleadyExists(newId)
        }
        area.id = newId
        areas.removeValue(forKey: oldId)
        areas[newId] = area
    }
}
