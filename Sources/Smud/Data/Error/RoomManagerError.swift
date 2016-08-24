//
// RoomManagerError.swift
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

enum RoomManagerError: Error, CustomStringConvertible {
    
    case areaNotSpecified
    case areaDoesNotExist(tag: Tag)
    case templateAlreadyExists(tag: Tag)
    case templateDoesNotExist(tag: Tag)
    case deleteError(tag: Tag)
    
    var description: String {
        switch self {
        case .areaNotSpecified: return "Please specify an area."
        case let .areaDoesNotExist(tag): return "Area \(tag) does not exist."
        case let .templateAlreadyExists(tag): return "Room template \(tag) already exists."
        case let .templateDoesNotExist(tag): return "Room template \(tag) does not exist."
        case let .deleteError(tag): return "Could not delete room template \(tag) from database."
        }
    }
}
