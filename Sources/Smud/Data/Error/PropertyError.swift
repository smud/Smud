//
// AreaManagerError.swift
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

enum PropertyError: Error, CustomStringConvertible {
    case notFound(property: String)
    
    var description: String {
        switch self {
        case let .notFound(property): return "Property '\(property)' not found."
        }
    }
}
