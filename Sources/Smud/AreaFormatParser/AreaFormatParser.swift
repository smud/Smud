//
// AreaFormatParser.swift
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
import CollectionUtils

let areasLog = false

class AreaFormatParser {
    typealias T = AreaFormatParser
    
    enum StructureType {
        case none
        case extended
        case base
    }
    
    var scanner: Scanner!
    var lineUtf16Offsets = [Int]()
    let worldPrototypes: WorldPrototypes
    let definitions: Definitions
    
    var fieldDefinitions: FieldDefinitions!
    var currentAreaId: String?
    var currentEntity: Entity!
    var animateByDefault = false
    var currentFieldInfo: FieldInfo?
    var currentFieldName = "" // struct.name
    var currentFieldNameWithIndex = "" // struct.name[0]
    var currentStructureType: StructureType = .none
    var currentStructureName = "" // struct
    var firstFieldInStructure = false
    
    private static let areaTagFieldName = "area"
    private static let roomTagFieldName = "room"
    private static let mobileTagFieldName = "mobile"
    private static let itemTagFieldName = "item"
    
    #if os(Linux) || os(Windows)
    // CharacterSet.union does not work in SwiftFoundation
    private static let wordCharacters: CharacterSet = {
        var c = CharacterSet.whitespacesAndNewlines
        c.insert(charactersIn: "/;:()[]=")
        c.invert()
        return c
    }()
    #else
    private static let wordCharacters = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "/;:()[]=")).inverted
    #endif
    
    #if os(Linux) || os(Windows)
    static let tagCharacters: CharacterSet = {
        var c = CharacterSet.alphanumerics
        c.insert(charactersIn: "_.")
        return c
    }()
    #else
    static let tagCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_."))
    #endif
    static let linkCharacters = tagCharacters
    
    public init(worldPrototypes: WorldPrototypes, definitions: Definitions) {
        self.worldPrototypes = worldPrototypes
        self.definitions = definitions
    }
    
    public func load(filename: String) throws {
        let contents: String
        do {
            contents = try String(contentsOfFile: filename, encoding: .utf8)
        } catch {
            throw AreaParseError(kind: .unableToLoadFile(error: error), scanner: nil)
        }

        scanner = Scanner(string: contents)
        currentAreaId = nil
        currentEntity = nil
        animateByDefault = false
        currentFieldInfo = nil
        currentFieldName = ""
        currentFieldNameWithIndex = ""
        currentStructureType = .none
        currentStructureName = ""
        firstFieldInStructure = false
        
        lineUtf16Offsets = findLineUtf16Offsets(text: contents)
        
        try skipComments()
        while !scanner.isAtEnd {
            try scanNextField()

            try skipComments()
        }
        
        try finalizeCurrentEntity()
        
        guard currentStructureType == .none else {
            try throwError(.unterminatedStructure)
        }
    }
    
    private func findLineUtf16Offsets(text: String) -> [Int] {
        var offsets = [0]
        
        var at = 0
        for cu in text.utf16 {
            if cu == 10 { // \n
                offsets.append(at + 1)
            }
            at += 1
        }
        
        return offsets
    }
    
    private func scanNextField() throws {
        try skipComments()
        
        guard let word = scanWord() else {
            try throwError(.expectedFieldName)
        }
        let (baseStructureName, field) = structureAndFieldName(word)
        
        if !baseStructureName.isEmpty {
            // Base format style structure name encountered: struct.field
            currentStructureType = .base
            currentStructureName = baseStructureName.lowercased()
            if areasLog {
                print("--- Base structure opened: \(currentStructureName)")
            }
        }

        var isNewEntity = false
        var isArea = false
        
        currentFieldName = field.lowercased()
        if currentStructureType == .none {
            switch currentFieldName {
            case T.areaTagFieldName:
                try finalizeCurrentEntity()
                isNewEntity = true
                isArea = true
                fieldDefinitions = definitions.areaFields
            case T.roomTagFieldName:
                try finalizeCurrentEntity()
                isNewEntity = true
                fieldDefinitions = definitions.roomFields
            case T.mobileTagFieldName:
                try finalizeCurrentEntity()
                isNewEntity = true
                fieldDefinitions = definitions.mobileFields
                animateByDefault = true
            case T.itemTagFieldName:
                try finalizeCurrentEntity()
                isNewEntity = true
                fieldDefinitions = definitions.itemFields
            default:
                break
            }
        }
        
        if currentStructureType != .none {
            currentFieldName = "\(currentStructureName).\(currentFieldName)"
        }
        
        let requireFieldSeparator: Bool
        if try openExtendedStructure() {
            if areasLog {
                print("--- Extended structure opened: \(currentStructureName)")
            }
            requireFieldSeparator = false
        } else {
            try scanValue()
            requireFieldSeparator = true
            
            if isNewEntity {
                // Prevent overwriting old entity with same id:
                
                // At this point both type and id of new entity are available.
                // Check if entity already exists and use the old one instead.
                let replaced = replaceCurrentEntityWithOldEntity()
                if areasLog {
                    if replaced {
                        print("Appending to old entity")
                    } else {
                        print("Created a new entity")
                    }
                }
                
                if isArea {
                    // Subsequent parsed entities will be assigned
                    // to this area until another area definition
                    // is encountered
                    setCurrentAreaId()
                }
            }
        }

        if currentStructureType == .base {
            currentStructureType = .none
            currentStructureName = ""
            if areasLog {
                print("--- Base structure closed")
            }
        } else if try closeExtendedStructure() {
            if areasLog {
                print("--- Extended structure closed")
            }
        }

        if requireFieldSeparator {
            try scanner.skipping(CharacterSet.whitespaces) {
                try skipComments()
                guard scanner.skipString(":") ||
                    scanner.skipString("\r\n") ||
                    scanner.skipString("\n") ||
                    scanner.isAtEnd
                else {
                    try throwError(.expectedFieldSeparator)
                }
            }
        }
    }
    
    private func assignIndexToNewStructure(named name: String) {
        if let current = currentEntity.lastStructureIndex[name] {
            currentEntity.lastStructureIndex[name] = current + 1
        } else {
            currentEntity.lastStructureIndex[name] = 0
        }
        if areasLog {
            print("assignIndexToNewStructure: named=\(name), index=\(currentEntity.lastStructureIndex[name]!)")
        }
    }
    
    private func openExtendedStructure() throws -> Bool {
        guard currentStructureType == .none else { return false }
        
        try skipComments()
        guard scanner.skipString("(") else {
            return false // Not a structure
        }
        
        currentStructureType = .extended
        currentStructureName = currentFieldName
        firstFieldInStructure = true
        
        assignIndexToNewStructure(named: currentStructureName)
        
        return true
    }

    private func closeExtendedStructure() throws -> Bool {
        guard currentStructureType == .extended else { return false }
        
        try skipComments()
        guard scanner.skipString(")") else {
            return false
        }
        
        currentStructureType = .none
        currentStructureName = ""
        firstFieldInStructure = false
        return true
    }
    
    private func appendCurrentIndex(toName name: String) -> String {
        if let structureName = structureName(fromFieldName: name),
            let index = currentEntity.lastStructureIndex[structureName] {
            return appendIndex(toName: name, index: index)
        }
        return name
    }

    private func scanValue() throws {
        if fieldDefinitions == nil {
            try throwError(.unsupportedEntityType)
        }
        guard let fieldInfo = fieldDefinitions.field(name: currentFieldName) else {
            try throwError(.unknownFieldType)
        }
        currentFieldInfo = fieldInfo
        
        switch currentStructureType {
        case .none:
            break
        case .base:
            // For base structures, assign a new index every time
            // a structure start field is encountered.
            if fieldInfo.flags.contains(.structureStart) {
                assignIndexToNewStructure(named: currentStructureName)
            }
        case .extended:
            // For extended structures, new index was assigned when
            // the structure was opened.
            if firstFieldInStructure {
                firstFieldInStructure = false
                if !fieldInfo.flags.contains(.structureStart) {
                    try throwError(.structureCantStartFromThisField)
                }
            }
        }
        
        if let name = structureName(fromFieldName: currentFieldName),
                let index = currentEntity.lastStructureIndex[name] {
            currentFieldNameWithIndex = appendIndex(toName: currentFieldName, index: index)
        } else {
            currentFieldNameWithIndex = currentFieldName
        }
        
        try skipComments()
        try scanner.skipping(CharacterSet.whitespaces) {
            switch fieldInfo.type {
            case .tag: try scanTag()
            case .link: try scanLink()
            case .number: try scanNumber()
            case .enumeration: try scanEnumeration()
            case .flags: try scanFlags()
            case .list: try scanList()
            case .dictionary: try scanDictionary()
            case .line: try scanLine()
            case .longText: try scanLongText()
            case .dice: try scanDice()
            //default: fatalError()
            }
            #if !os(Linux) && !os(Windows)
            // Coredumps on Linux
            assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
            #endif
        }
    }
    
    private func findOrCreateArea(id: String) -> AreaPrototype {
        let lowercasedId = id.lowercased()
        if let area = worldPrototypes.areaPrototypesByLowercasedId[lowercasedId] {
            return area
        } else {
            let area = AreaPrototype()
            worldPrototypes.areaPrototypesByLowercasedId[lowercasedId] = area
            return area
        }
    }

    private func finalizeCurrentEntity() throws {
        if let entity = currentEntity {
            if let area = entity.value(named: T.areaTagFieldName),
                case .tag(let areaId) = area {
                    let area = findOrCreateArea(id: areaId)
                    area.entity = entity
                
            } else if let room = entity.value(named: T.roomTagFieldName),
                case .tag(let roomId) = room {
                    guard let currentAreaId = currentAreaId else {
                        try throwError(.noCurrentArea)
                    }
                    let area = findOrCreateArea(id: currentAreaId)
                    area.roomsById[roomId] = entity
                
            } else if let mobile = entity.value(named: T.mobileTagFieldName),
                case .tag(let mobileId) = mobile {
                    guard let currentAreaId = currentAreaId else {
                        try throwError(.noCurrentArea)
                    }
                    let area = findOrCreateArea(id: currentAreaId)
                    area.mobilesById[mobileId] = entity
                
            } else if let item = entity.value(named: T.itemTagFieldName),
                let currentAreaId = currentAreaId,
                case .tag(let itemId) = item {
                    let area = findOrCreateArea(id: currentAreaId)
                    area.itemsById[itemId] = entity
                
            } else {
                try throwError(.unknownEntityType)
            }
            
            if areasLog {
                print("---")
            }
        }
        
        currentEntity = Entity()
        animateByDefault = false
        currentEntity.startLine = lineAtUtf16Offset(scanner.scanLocation)
        //print("\(scanner.scanLocation): \(currentEntity.startLine)")
    }
    
    private func setCurrentAreaId() {
        guard let entity = currentEntity else {
            assertionFailure()
            return
        }
        
        guard let area = entity.value(named: T.areaTagFieldName),
            case .tag(let areaId) = area else {
                assertionFailure()
                return
        }
        
        currentAreaId = areaId
    }
    
    private func replaceCurrentEntityWithOldEntity() -> Bool {
        guard let entity = currentEntity else { return false }
        
        if let area = entity.value(named: T.areaTagFieldName),
            case .tag(let areaId) = area,
            let oldEntity = worldPrototypes.areaPrototypesByLowercasedId[areaId.lowercased()] {
                currentEntity = oldEntity.entity

        } else if let room = entity.value(named: T.roomTagFieldName),
            case .tag(let roomId) = room,
            let currentAreaId = currentAreaId,
            let oldEntity = worldPrototypes.areaPrototypesByLowercasedId[currentAreaId.lowercased()]?.roomsById[roomId] {
                currentEntity = oldEntity
        
        } else if let mobile = entity.value(named: T.mobileTagFieldName),
            case .tag(let mobileId) = mobile,
            let currentAreaId = currentAreaId,
            let oldEntity = worldPrototypes.areaPrototypesByLowercasedId[currentAreaId.lowercased()]?.mobilesById[mobileId] {
                currentEntity = oldEntity
        
        } else if let item = entity.value(named: T.itemTagFieldName),
            case .tag(let itemId) = item,
            let currentAreaId = currentAreaId,
            let oldEntity = worldPrototypes.areaPrototypesByLowercasedId[currentAreaId.lowercased()]?.itemsById[itemId] {
                currentEntity = oldEntity
        
        } else {
            return false
        }
        
        return true
    }

    func skipComments() throws {
        while true {
            if scanner.skipString(";") {
                let previousCharactersToBeSkipped = scanner.charactersToBeSkipped
                scanner.charactersToBeSkipped = nil
                defer { scanner.charactersToBeSkipped = previousCharactersToBeSkipped }
                
                // If at "\n" already, do nothing
                //guard !scanner.skipString("\n") else { continue }
                //guard !scanner.skipString("\r\n") else { continue }
                guard let cu = scanner.peekUtf16CodeUnit(),
                    cu != 10 && cu != 13 else { continue }
                
                guard scanner.skipUpToCharacters(from: CharacterSet.newlines) else {
                    // No more newlines, skip until the end of text
                    scanner.scanLocation = scanner.string.utf16.count
                    return
                }
                // No: parser will expect field separator
                //if !scanner.skipString("\n") {
                //    scanner.skipString("\r\n")
                //}
            } else if scanner.skipString("/*") {
                guard scanner.skipUpTo("*/") else {
                    throw AreaParseError(kind: .unterminatedComment, scanner: scanner)
                }
                scanner.skipString("*/")
            } else {
                return
            }
        }
    }
    
    func scanQuotedText() throws -> String {
        var result = ""
        try scanner.skipping(CharacterSet.whitespacesAndNewlines) {
            guard scanner.skipString("\"") else {
                try throwError(.expectedDoubleQuote)
            }
        }
        try scanner.skipping(nil) {
            while true {
                if scanner.skipString("\"") {
                    // End of string or escaped quote?
                    if let cu = scanner.peekUtf16CodeUnit(), cu == 34 { // "
                        // If a quote is immediately followed by another quote,
                        // this is an escaped quote
                        scanner.skipString("\"")
                        result += "\""
                        continue
                    } else {
                        // End of string
                        break
                    }
                }
                
                guard let text = scanner.scanUpTo("\"") else {
                    try throwError(.unterminatedString)
                }
                result += text
            }
        }
        return result
    }
    
    func escapeText(_ text: String) -> String {
        return text.components(separatedBy: "\"").joined(separator: "\"\"")
    }
    
    func scanWord() -> String? {
        return scanner.scanCharacters(from: T.wordCharacters)
    }
    
    private func lineAtUtf16Offset(_ offset: Int) -> Int {
        return lineUtf16Offsets.binarySearch { $0 < offset } /* - 1 */
    }
    
    func throwError(_ kind: AreaParseError.Kind) throws -> Never  {
        throw AreaParseError(kind: kind, scanner: scanner)
    }
}
