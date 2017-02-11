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

public enum Direction: String {
    case north
    case east
    case south
    case west
    case up
    case down

    public var opposite: Direction {
        switch self {
        case .north: return .south
        case .east:  return .west
        case .south: return .north
        case .west:  return .east
        case .up:    return .down
        case .down:  return .up
        }
    }
    
    public var abbreviated: String {
        switch self {
        case .north: return "n"
        case .east:  return "e"
        case .south: return "s"
        case .west:  return "w"
        case .up:    return "u"
        case .down:  return "d"
        }
    }
    
    public static var orderedDirections: [Direction] {
        return [.north, .east, .south, .west, .up, .down]
    }
}
