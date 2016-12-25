//
// Entity.swift
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

public class Entity {
    private var lastAddedIndex = 0
    
    // Key is "structure name"."field name"[index]:
    // struct.name[0]
    // Index should be omitted for top level fields.
    private var values = [String: Value]()
    private(set) var orderedNames = [String]()
    
    var lastStructureIndex = [String: Int]()
    var startLine = 0

    // name is struct.field[index]
    func add(name: String, value: Value) -> Bool {
        guard values[name] == nil else { return false }
        values[name] = value
        orderedNames.append(name)
        return true
    }
    
    // name is struct.field[index]
    func replace(name: String, value: Value) {
        guard values[name] == nil else {
            values[name] = value
            return
        }
        values[name] = value
        orderedNames.append(name)
    }
    
    // name is struct.field[index]
    func value(named name: String) -> Value? {
        return values[name]
    }
    
    // name is struct.field WITHOUT [index] suffix
    func hasRequiredField(named name: String) -> Bool {
        if let structureName = structureName(fromFieldName: name) {
            guard let lastIndex = lastStructureIndex[structureName] else {
                // This is a structure field, but no structures were created
                return true
            }
            // Every structure should have required field:
            for i in 0...lastIndex {
                let nameWithIndex = appendIndex(toName: name, index: i)
                guard values[nameWithIndex] != nil else { return false }
            }
            return true
        }
        
        return values[name] != nil
    }
}
