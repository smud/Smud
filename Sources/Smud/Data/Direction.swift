//
// Direction.swift
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

enum Direction: String, EnumerableField {
    case north
    case eash
    case south
    case west
    case up
    case down
    
    init(_ string: String) throws {
        let scanner = Scanner(string: string)
        guard let word = scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines) else {
            throw AreaParseError.invalidFormat(details: "Expected a single word")
        }
        guard let direction = Direction(rawValue: word) else {
            throw AreaParseError.invalidFormat(details: "Invalid value: \(word)")
        }
        
        self = direction
    }
    
    var stringValue: String { return rawValue }
}
