//
// EntityPattern.swift
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

public class EntityPattern {
    typealias T = EntityPattern
    static let keywordCharacterSet = CharacterSet.whitespacesAndNewlines
        .union(CharacterSet.decimalDigits)
        .union(CharacterSet(charactersIn: ".*"))
        .inverted
    static let otherCharacterSet = T.keywordCharacterSet.inverted
    
    public var startingIndex = 1
    public var count = 1
    public var keywords = [String]()
    
    public init(_ string: String) {
        let scanner = Scanner(string: string)
        
        while !scanner.isAtEnd {
            if let value = scanner.scanInteger() {
                if scanner.skipString(".") {
                    startingIndex = value
                } else if scanner.skipString("*") {
                    count = value
                }
            } else if let keyword = scanner.scanCharacters(from: T.keywordCharacterSet) {
                keywords.append(keyword)
                scanner.skipString(".")
            } else {
                scanner.skipCharacters(from: T.otherCharacterSet)
            }
        }
    }

    public func matches(creature: Creature) -> Bool {
        for keyword in keywords {
            if !keyword.isPrefix(ofOneOf: creature.nameKeywords, caseInsensitive: true) {
                return false
            }
        }
        
        return true
    }
}
