//
// Value.swift
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

enum Value {
    case tag(String)
    case link(Link)
    case number(Int64)
    case enumeration(Int64)
    case flags(Int64)
    case list(Set<Int64>)
    case dictionary([Int64: Int64?])
    case line(String)
    case longText([String])
    case dice(Int64, Int64, Int64)
    
    var string: String? {
        switch self {
        case .tag(let value): return value
        case .line(let value): return value
        default: return nil
        }
    }
    
    var int: Int? {
        switch self {
        case .number(let value): return Int(value)
        default: return nil
        }
    }
    
    var link: Link? {
        switch self {
        case .link(let value): return value
        default: return nil
        }
    }
}
