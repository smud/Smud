//
// AreaFormatParser+Types.swift
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
    func scanNumber() throws {
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
    
    func scanEnumeration() throws {
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
    
    func scanFlags() throws {
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
    
    func scanList() throws {
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
    
    func scanDictionary() throws {
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
    
    func scanTag() throws {
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
    
    func scanLink() throws {
        #if !os(Linux) && !os(Windows)
            assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif
        
        guard scanner.skipString("#") else {
            try throwError(.linkShouldStartWithHash)
        }
        
        var result: Link?
        try scanner.skipping(nil) {
            guard let linkString = scanner.scanCharacters(from: T.linkCharacters), !linkString.isEmpty, let link = Link("#" + linkString) else {
                try throwError(.invalidLinkFormat)
            }
            result = link
        }
        
        let value = Value.link(result!)
        if currentEntity.value(named: currentFieldNameWithIndex) != nil {
            try throwError(.duplicateField)
        }
        currentEntity.replace(name: currentFieldNameWithIndex, value: value)
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result.unwrapOptional)")
        }
    }
    
    func scanLine() throws {
        #if !os(Linux) && !os(Windows)
            assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif
        
        let result = try scanQuotedText()
        //if currentFieldInfo?.flags.contains(.automorph) ?? false {
        //    result = morpher.convertToSimpleAreaFormat(text: result,
        //        animateByDefault: animateByDefault)
        //}
        let value = Value.line(result)
        if currentEntity.value(named: currentFieldNameWithIndex) != nil {
            try throwError(.duplicateField)
        }
        currentEntity.replace(name: currentFieldNameWithIndex, value: value)
        if areasLog {
            print("\(currentFieldNameWithIndex): \(result)")
        }
    }
    
    func scanLongText() throws {
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
    
    func scanDice() throws {
        #if !os(Linux) && !os(Windows)
            assert(scanner.charactersToBeSkipped == CharacterSet.whitespaces)
        #endif
        
        guard let v1 = scanner.scanInt64() else {
            try throwError(.expectedNumber)
        }
        
        let hasK = scanner.skipString("D") || scanner.skipString("d")
        
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
                print("\(currentFieldNameWithIndex): 0d0+\(v1)")
            }
        } else {
            value = Value.dice(v1, (v2OrNil ?? 0), (v3OrNil ?? 0))
            if areasLog {
                print("\(currentFieldNameWithIndex): \(v1)d\(v2OrNil ?? 0)+\(v3OrNil ?? 0)")
            }
        }
        
        if currentEntity.value(named: currentFieldNameWithIndex) != nil {
            try throwError(.duplicateField)
        }
        currentEntity.replace(name: currentFieldNameWithIndex, value:  value)
    }
}
