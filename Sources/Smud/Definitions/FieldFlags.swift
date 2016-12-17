//
// FieldFlags.swift
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

public struct FieldFlags: OptionSet {
    public let rawValue: Int
    
    public static let required   = FieldFlags(rawValue: 1 << 0)
    public static let newLine    = FieldFlags(rawValue: 1 << 1)
    public static let structureStart = FieldFlags(rawValue: 1 << 2)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
