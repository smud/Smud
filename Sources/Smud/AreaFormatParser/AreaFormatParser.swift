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

let areasLog = true

class AreaFormatParser {
    private typealias T = AreaFormatParser
    
    private enum StructureType {
        case none
        case extended
        case base
    }
    
    private var scanner: Scanner!
    private var lineUtf16Offsets = [Int]()
    private let world: World
    private let definitions: Definitions
    
    private var fieldDefinitions: FieldDefinitions!
    private var currentAreaId: String?
    private var currentEntity: Entity!
    private var animateByDefault = false
    private var currentFieldInfo: FieldInfo?
    private var currentFieldName = "" // struct.name
    private var currentFieldNameWithIndex = "" // struct.name[0]
    private var currentStructureType: StructureType = .none
    private var currentStructureName = "" // struct
    private var firstFieldInStructure = false
    
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
    private static let tagCharacters: CharacterSet = {
        var c = CharacterSet.alphanumerics
        c.insert(charactersIn: "_")
        return c
    }()
    #else
    private static let tagCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
    #endif
    
    init(world: World, definitions: Definitions) {
        self.world = world
        self.definitions = definitions
    }
    
    func load(filename: String) throws {
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
    
    private func scanNumber() throws {
        #if !os(Linux) && !os(Windows)
        // Coredumps on Linux
        assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif

        guard let result = scanner.scanInt64() else {
            try throwError(.expectedNumber)
        }
        let value = Value.number(result)
        guard currentEntity.add(name: currentFieldNameWithIndex, value: value) else {
            try throwError(.duplicateField)
        }
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result)")
        }
    }
    
    private func scanEnumeration() throws {
        #if !os(Linux) && !os(Windows)
        // Coredumps on Linux
        assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif

        let value: Value
        if let number = scanner.scanInt64() {
            value = Value.enumeration(number)
            if areasLog {
                print("\(currentFieldNameWithIndex): .\(number)")
            }
        } else if let word = scanWord() {
            let result = word.lowercased()
            guard let valuesByName = definitions.enumerations.valuesByNameForAlias[currentFieldName],
                    let number = valuesByName[result] else {
                try throwError(.invalidEnumerationValue)
            }
            value = Value.enumeration(number)
            if areasLog {
                print("\(currentFieldNameWithIndex): .\(number)")
            }
        } else {
            try throwError(.expectedEnumerationValue)
        }
        
        guard currentEntity.add(name: currentFieldNameWithIndex, value: value) else {
            try throwError(.duplicateField)
        }
    }
    
    private func scanFlags() throws {
        #if !os(Linux) && !os(Windows)
        // Coredumps on Linux
        assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif

        let valuesByName = definitions.enumerations.valuesByNameForAlias[currentFieldName]
        
        var result: Int64
        if let previousValue = currentEntity.value(named: currentFieldNameWithIndex),
            case .flags(let previousResult) = previousValue {
                result = previousResult
        } else {
                result = 0
        }

        while true {
            if let flags = scanner.scanInt64() {
                //let flags: Int64 = bitNumber <= 0 ? 0 : 1 << (bitNumber - 1)
                guard (result & flags) == 0 else {
                    try throwError(.duplicateValue)
                }
                result |= flags
            } else if let word = scanWord()?.lowercased() {
                guard let valuesByName = valuesByName else {
                    // List without associated enumeration names
                    try throwError(.expectedNumber)
                }
                guard let bitNumber = valuesByName[word] else {
                    try throwError(.invalidEnumerationValue)
                }
                let flags = bitNumber <= 0 ? 0 : 1 << (bitNumber - 1)
                guard (result & flags) == 0 else {
                    try throwError(.duplicateValue)
                }
                result |= flags
            } else {
                break
            }
        }

        let value = Value.flags(result)
        currentEntity.replace(name: currentFieldNameWithIndex, value: value)
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result)")
        }
    }

    private func scanList() throws {
        #if !os(Linux) && !os(Windows)
        // Coredumps on Linux
        assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif

        let valuesByName = definitions.enumerations.valuesByNameForAlias[currentFieldName]
        
        var result: Set<Int64>
        if let previousValue = currentEntity.value(named: currentFieldNameWithIndex),
            case .list(let previousResult) = previousValue {
            result = previousResult
        } else {
            result = Set<Int64>()
        }
        
        while true {
            if let number = scanner.scanInt64() {
                guard result.insert(number).inserted else {
                    try throwError(.duplicateValue)
                }
            } else if let word = scanWord()?.lowercased() {
                guard let valuesByName = valuesByName else {
                    // List without associated enumeration names
                    try throwError(.expectedNumber)
                }
                guard let number = valuesByName[word] else {
                    try throwError(.invalidEnumerationValue)
                }
                guard result.insert(number).inserted else {
                    try throwError(.duplicateValue)
                }
            } else {
                break
            }
        }

        let value = Value.list(result)
        currentEntity.replace(name: currentFieldNameWithIndex, value:  value)
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result)")
        }
    }

    private func scanDictionary() throws {
        #if !os(Linux) && !os(Windows)
        // Coredumps on Linux
        assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif
        
        let valuesByName = definitions.enumerations.valuesByNameForAlias[currentFieldName]
        
        var result: [Int64: Int64?]
        if let previousValue = currentEntity.value(named: currentFieldNameWithIndex),
            case .dictionary(let previousResult) = previousValue {
            result = previousResult
        } else {
            result = [Int64: Int64?]()
        }
        
        while true {
            if let key = scanner.scanInt64() {
                guard result[key] == nil else {
                    try throwError(.duplicateValue)
                }
                if scanner.skipString("=") {
                    guard let value = scanner.scanInt64() else {
                        try throwError(.expectedNumber)
                    }
                    result[key] = value
                } else {
                    result[key] = nil as Int64?
                }
            } else if let word = scanWord()?.lowercased() {
                guard let valuesByName = valuesByName else {
                    // List without associated enumeration names
                    try throwError(.expectedNumber)
                }
                guard let key = valuesByName[word] else {
                    try throwError(.invalidEnumerationValue)
                }
                guard result[key] == nil else {
                    try throwError(.duplicateValue)
                }
                if scanner.skipString("=") {
                    guard let value = scanner.scanInt64() else {
                        try throwError(.expectedNumber)
                    }
                    result[key] = value
                } else {
                    result[key] = nil as Int64?
                }
            } else {
                break
            }
        }
        
        let value = Value.dictionary(result)
        currentEntity.replace(name: currentFieldNameWithIndex, value: value)
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result)")
        }
    }

    private func scanQuotedText() throws -> String {
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

    private func scanTag() throws {
        #if !os(Linux) && !os(Windows)
            assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif

        guard scanner.skipString("#") else {
            try throwError(.tagShouldStartWithHash)
        }
        
        var result = ""
        try scanner.skipping(nil) {
            guard let tag = scanner.scanCharacters(from: T.tagCharacters), !tag.isEmpty else {
                try throwError(.invalidTagFormat)
            }
            result = tag
        }
        
        let value = Value.tag(result)
        if currentEntity.value(named: currentFieldNameWithIndex) != nil {
            try throwError(.duplicateField)
        }
        currentEntity.replace(name: currentFieldNameWithIndex, value: value)
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result)")
        }
    }

    private func scanLink() throws {
        #if !os(Linux) && !os(Windows)
            assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif
        
        guard scanner.skipString("#") else {
            try throwError(.tagShouldStartWithHash)
        }
        
        var result = ""
        try scanner.skipping(nil) {
            guard let tag = scanner.scanCharacters(from: T.tagCharacters), !tag.isEmpty else {
                try throwError(.invalidTagFormat)
            }
            result = tag
        }
        
        let value = Value.link(result)
        if currentEntity.value(named: currentFieldNameWithIndex) != nil {
            try throwError(.duplicateField)
        }
        currentEntity.replace(name: currentFieldNameWithIndex, value: value)
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result)")
        }
    }

    private func scanLine() throws {
        #if !os(Linux) && !os(Windows)
        assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif

        let result = try scanQuotedText()
        //if currentFieldInfo?.flags.contains(.automorph) ?? false {
        //    result = morpher.convertToSimpleAreaFormat(text: result,
        //        animateByDefault: animateByDefault)
        //}
        let value = Value.line([result])
        if currentEntity.value(named: currentFieldNameWithIndex) != nil {
            try throwError(.duplicateField)
        }
        currentEntity.replace(name: currentFieldNameWithIndex, value: value)
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result)")
        }
    }
    
    private func scanLongText() throws {
        #if !os(Linux) && !os(Windows)
        assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif

        var result = [try scanQuotedText()]
        while true {
            do {
                #if !os(Linux) && !os(Windows)
                assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
                #endif
                try scanner.skipping(CharacterSet.whitespacesAndNewlines) {
                    let nextLine = try scanQuotedText()
                    result.append(nextLine)
                    try skipComments()
                }
            } catch let error as AreaParseError {
                if case .expectedDoubleQuote = error.kind {
                    // It's normal to not have continuation lines
                    break
                } else {
                    throw error
                }
            }
        }
        //if currentFieldInfo?.flags.contains(.automorph) ?? false {
        //    result = result.map {
        //        morpher.convertToSimpleAreaFormat(text: $0, animateByDefault: animateByDefault)
        //    }
        //}
        let value = Value.longText(result)
        if currentEntity.value(named: currentFieldNameWithIndex) != nil {
            try throwError(.duplicateField)
        }
        currentEntity.replace(name: currentFieldNameWithIndex, value:  value)
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result)")
        }
    }
    
    private func scanDice() throws {
        #if !os(Linux) && !os(Windows)
        assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif
        
        guard let v1 = scanner.scanInt64() else {
            try throwError(.expectedNumber)
        }
        
        let hasK = scanner.skipString("К") || scanner.skipString("к")

        let v2OrNil = scanner.scanInt64()
        
        let hasPlus = scanner.skipString("+")

        let v3OrNil = scanner.scanInt64()
        
        if hasK && v2OrNil == nil {
            try throwError(.syntaxError)
        }
        if hasPlus && (v2OrNil == nil || v3OrNil == nil) {
            try throwError(.syntaxError)
        }
        
        let value: Value
        if v2OrNil == nil && v3OrNil == nil {
            value = Value.dice(0, 0, v1)
            if areasLog {
                print("\(currentFieldNameWithIndex): 0к0+\(v1)")
            }
        } else {
            value = Value.dice(v1, (v2OrNil ?? 0), (v3OrNil ?? 0))
            if areasLog {
                print("\(currentFieldNameWithIndex): \(v1)к\(v2OrNil ?? 0)+\(v3OrNil ?? 0)")
            }
        }

        if currentEntity.value(named: currentFieldNameWithIndex) != nil {
            try throwError(.duplicateField)
        }
        currentEntity.replace(name: currentFieldNameWithIndex, value:  value)
    }
    
    private func findOrCreateArea(id: String) -> Area {
        if let area = world.areas[id] {
            return area
        } else {
            let area = Area()
            world.areas[id] = area
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
                let currentAreaId = currentAreaId,
                case .tag(let roomId) = room {
                    let area = findOrCreateArea(id: currentAreaId)
                    area.rooms[roomId] = entity
                
            } else if let mobile = entity.value(named: T.mobileTagFieldName),
                let currentAreaId = currentAreaId,
                case .tag(let mobileId) = mobile {
                    let area = findOrCreateArea(id: currentAreaId)
                    area.mobiles[mobileId] = entity
                
            } else if let item = entity.value(named: T.itemTagFieldName),
                let currentAreaId = currentAreaId,
                case .tag(let itemId) = item {
                    let area = findOrCreateArea(id: currentAreaId)
                    area.items[itemId] = entity
                
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
            let oldEntity = world.areas[areaId] {
                currentEntity = oldEntity.entity

        } else if let room = entity.value(named: T.roomTagFieldName),
            case .tag(let roomId) = room,
            let currentAreaId = currentAreaId,
            let oldEntity = world.areas[currentAreaId]?.rooms[roomId] {
                currentEntity = oldEntity
        
        } else if let mobile = entity.value(named: T.mobileTagFieldName),
            case .tag(let mobileId) = mobile,
            let currentAreaId = currentAreaId,
            let oldEntity = world.areas[currentAreaId]?.mobiles[mobileId] {
                currentEntity = oldEntity
        
        } else if let item = entity.value(named: T.itemTagFieldName),
            case .tag(let itemId) = item,
            let currentAreaId = currentAreaId,
            let oldEntity = world.areas[currentAreaId]?.items[itemId] {
                currentEntity = oldEntity
        
        } else {
            return false
        }
        
        return true
    }

    private func skipComments() throws {
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
    
    private func scanWord() -> String? {
        return scanner.scanCharacters(from: T.wordCharacters)
    }
    
    private func lineAtUtf16Offset(_ offset: Int) -> Int {
        return lineUtf16Offsets.binarySearch { $0 < offset } /* - 1 */
    }
    
    private func throwError(_ kind: AreaParseError.Kind) throws -> Never  {
        throw AreaParseError(kind: kind, scanner: scanner)
    }
}
