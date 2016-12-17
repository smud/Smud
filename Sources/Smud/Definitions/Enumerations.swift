//
// Enumerations.swift
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

class Enumerations {
    typealias NamesByValue = [Int64: String]
    typealias ValuesByName = [String: Int64]
    
    var namesByValueForAlias = [String: NamesByValue]()
    var valuesByNameForAlias = [String: ValuesByName]()
    
    func add(aliases: [String], namesByValue: NamesByValue) {
        
        var namesByValueLower = NamesByValue()
        for (k, v) in namesByValue {
            namesByValueLower[k] = v
        }
        
        var valuesByNameLower = ValuesByName()
        for (k, v) in namesByValueLower {
            valuesByNameLower[v] = k
        }
        
        for alias in aliases {
            let alias = alias.lowercased()
            namesByValueForAlias[alias] = namesByValueLower
            valuesByNameForAlias[alias] = valuesByNameLower
        }
    }
}
