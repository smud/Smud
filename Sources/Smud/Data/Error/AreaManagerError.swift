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

enum AreaManagerError: Error, CustomStringConvertible {
    
    case alreadyExists(tag: String)
    case doesNotExist(tag: String)
    case deleteError(tag: String)
    
    var description: String {
        switch self {
        case let .alreadyExists(tag): return "Area tagged #\(tag) already exists."
        case let .doesNotExist(tag): return "Area tagged #\(tag) does not exist."
        case let .deleteError(tag): return "Could not delete area tagged #\(tag) from database."
        }
    }
}
