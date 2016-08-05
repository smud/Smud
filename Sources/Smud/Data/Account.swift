//
// Account.swift
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

struct Account {
    var id: Int
    
    var email: String
}

extension Account: Hashable {
    var hashValue: Int { return id }
    
    static func ==(lhs: Account, rhs: Account) -> Bool {
        return lhs.id == rhs.id
    }
}
