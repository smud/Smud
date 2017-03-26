//
// AreaFormatParser+Save.swift
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

extension AreaFormatParser {
    func saveArea(id areaId: String, toDirectory directory: URL) throws {
        guard let areaPrototype = worldPrototypes.areaPrototypesByLowercasedId[areaId.lowercased()] else {
            throw AreaSaveError(kind: .areaPrototypeNotFound)
        }
        
        guard let areaIdField = idField(ofEntity: areaPrototype.entity, withDefinitions: definitions.areaFields) else {
            throw AreaSaveError(kind: .noAreaId)
        }

        let areaFilename = directory.appendingPathComponent("area.smud_", isDirectory: false)
        try saveEntities([areaPrototype.entity], describedBy: definitions.areaFields, toFile: areaFilename.relativePath)
        
        let itemsFilename = directory.appendingPathComponent("items.smud_", isDirectory: false)
        let items = areaPrototype.itemsById.sorted { $0.0 < $1.0 }.map { $0.value }
        try saveEntities(items, describedBy: definitions.itemFields, prefixedBy: areaIdField,  toFile: itemsFilename.relativePath)
        
        let mobilesFilename = directory.appendingPathComponent("mobiles.smud_", isDirectory: false)
        let mobiles = areaPrototype.mobilesById.sorted { $0.0 < $1.0 }.map { $0.value }
        try saveEntities(mobiles, describedBy: definitions.mobileFields, prefixedBy: areaIdField,  toFile: mobilesFilename.relativePath)

        let roomsFilename = directory.appendingPathComponent("rooms.smud_", isDirectory: false)
        let rooms = areaPrototype.roomsById.sorted { $0.0 < $1.0 }.map { $0.value }
        try saveEntities(rooms, describedBy: definitions.roomFields, prefixedBy: areaIdField,  toFile: roomsFilename.relativePath)
    }
    
    private func saveEntities(_ entities: [Entity], describedBy definitions: FieldDefinitions, prefixedBy prefix: String = "", toFile filename: String) throws {
        var output = prefix
        if !output.isEmpty {
            output += "\n\n"
        }
        
        for entity in entities {
            if entity !== entities.first {
                output += "\n"
            }
            output += exportEntity(entity, definitions: definitions)
        }
        try output.write(toFile: filename, atomically: true, encoding: .utf8)
    }
    
    private func exportEntity(_ entity: Entity, definitions: FieldDefinitions) -> String {
        guard let entityIdField = idField(ofEntity: entity, withDefinitions: definitions) else {
            return "// Skipping entity without id"
        }
        var output = entityIdField
        output += "\n"
        
        for fieldName in entity.orderedLowercasedNames {
            let (fieldNameWithoutIndex, index) = removeIndex(fromName: fieldName)
            guard let fieldInfo = definitions.field(name: fieldNameWithoutIndex) else { continue }

            // Entity id already printed
            guard !fieldInfo.flags.contains(.entityId) else { continue }
            
            guard let field = exportField(field: fieldInfo, index: index, inEntity: entity) else { continue }

            output += "    "
            output += field
            output += "\n"
        }
        return output
    }
    
    private func idField(ofEntity entity: Entity, withDefinitions definitions: FieldDefinitions) -> String? {
        guard let entityIdFieldName = definitions.entityIdFieldName(),
            let entityIdFieldInfo = definitions.field(name: entityIdFieldName),
            let entityIdField = exportField(field: entityIdFieldInfo, inEntity: entity) else {
                return nil
        }
        return entityIdField
    }
    
    private func exportField(field: FieldInfo, index: Int? = nil, inEntity entity: Entity) -> String? {
        let name = index != nil
            ? appendIndex(toName: field.name, index: index!)
            : field.name
        guard let value = entity.value(named: name) else {
            assertionFailure()
            return nil
        }
        
        switch value {
        case .tag(let value):
            guard isValidTag(value) else {
                assertionFailure()
                return nil
            }
            return "\(field.name) #\(value)"
        case .link(let value):
            value.instanceIndex = nil // Saving instance numbers makes no sense
            return "\(field.name) \(value)"
        case .number(let value):
            return "\(field.name) \(value)"
        case .enumeration(let value):
            return "\(field.name) \(value)" // TODO: use names
        case .flags(let value):
            return "\(field.name) \(value)" // TODO: use names
        case .list(let values):
            let value = Array(values).map { String($0) }.joined(separator: " ")
            return "\(field.name) \(value)" // TODO: use names
        case .dictionary(let valuesAndKeys):
            let value = valuesAndKeys.map { $1 == nil ? String($0) : "\($0):\($1!)" }.joined(separator: " ")
            return "\(field.name) \(value)" // TODO: use names
        case .line(let line):
            guard isSingleLine(line) else {
                assertionFailure()
                return nil
            }
            let value = escapeText(line)
            return "\(field.name) \"\(value)\""
        case .longText(let lines):
            let text = lines.joined(separator: " ")
            let value = escapeText(text)
            return "\(field.name) \"\(value)\""
        case let .dice(x, y, z):
            let value: String
            if x != 0 && y != 0 {
                if z != 0 {
                    value = "\(x)d\(y)+\(z)"
                } else {
                    value = "\(x)d\(y)"
                }
            } else {
                value = String(z)
            }
            return "\(name) \(value)"
        }
    }
    
    private func isValidTag(_ tag: String) -> Bool {
        return nil == tag.rangeOfCharacter(from: T.tagCharacters.inverted)
    }
    
    private func isSingleLine(_ line: String) -> Bool {
        return nil == line.rangeOfCharacter(from: CharacterSet.newlines)
    }
}

struct AreaSaveError: Error, CustomStringConvertible {
    enum Kind: CustomStringConvertible {
        case areaPrototypeNotFound
        case noAreaId
        
        var description: String {
            switch self {
            case .areaPrototypeNotFound: return "area prototype not found"
            case .noAreaId: return "no area id"
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
