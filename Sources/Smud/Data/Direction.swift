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

enum Direction: String, AreaFormatConvertible {
    case north
    case eash
    case south
    case west
    case up
    case down
    
    init(areaFormat: String) throws {
        let scanner = Scanner(string: areaFormat)
        guard let word = scanner.scanUpToCharacters(from: CharacterSet.whitespacesAndNewlines) else {
            throw AreaFormatError.parseError("Expected a single word")
        }
        guard let direction = Direction(rawValue: word) else {
            throw AreaFormatError.parseError("Invalid value: \(word)")
        }
        
        self = direction
    }
    
    var areaFormat: String { return rawValue }
}
