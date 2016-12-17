//
// FieldDefinitions.swift
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

class FieldDefinitions {
    //private var structureNames = Set<String>()
    private var fields = [String: FieldInfo]()
    private(set) public var requiredFieldNames = [String]()
    
    func field(name: String) -> FieldInfo? {
        return fields[name]
    }

    func insert(fieldInfo: FieldInfo) throws {
        guard fields[fieldInfo.name] == nil else {
            throw FieldDefinitionsError(kind: .duplicateFieldDefinition(fieldInfo: fieldInfo))
        }
        fields[fieldInfo.name] = fieldInfo
        if fieldInfo.flags.contains(.required) {
            requiredFieldNames.append(fieldInfo.name)
        }
    }
    
    func insert(name: String, type: FieldType, flags: FieldFlags = [])  throws {
        let fieldInfo = FieldInfo(name: name, type: type, flags: flags)
        try insert(fieldInfo: fieldInfo)
    }
    
    // Returns true if structure has not been registered before
    //private func registerStructure(name: String) -> Bool {
    //    guard !structureNames.contains(name) else { return false }
    //    structureNames.insert(name)
    //    return true
    //}
}

struct FieldDefinitionsError: Error, CustomStringConvertible {
    enum Kind: CustomStringConvertible {
        case duplicateFieldDefinition(fieldInfo: FieldInfo)
    
        var description: String {
            switch self {
            case .duplicateFieldDefinition(let fieldInfo):
                return "Duplicate field definition: \(fieldInfo.name)"
            }
        }
    }
    
    let kind: Kind

    var description: String {
        return kind.description
    }
    
    var localizedDescription: String {
        return description
    }
}
