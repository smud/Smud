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

final class Account: Modifiable {
    // Indexes
    fileprivate static var accountsByLowercasedEmail = [String: Account]()
    fileprivate static var accountsById = [Int64: Account]()

    // Modifiable
    static var modifiedEntities = Set<Account>()
    var deleted = false

    var accountId: Int64?
    var email = ""
}

extension Account: Equatable {
    static func ==(lhs: Account, rhs: Account) -> Bool {
        return lhs.accountId == rhs.accountId
    }
}

extension Account: Hashable {
    var hashValue: Int { return accountId?.hashValue ?? 0 }
}

extension Account {
    static func addToIndexes(account: Account) {
        guard let accountId = account.accountId else { fatalError() }
        
        accountsById[accountId] = account
        accountsByLowercasedEmail[account.email.lowercased()] = account
    }
    
    static func removeFromIndexes(account: Account) {
        guard let accountId = account.accountId else { fatalError() }
        
        accountsById.removeValue(forKey: accountId)
        accountsByLowercasedEmail.removeValue(forKey: account.email.lowercased())
    }
    
    static func with(id: Int64) -> Account? {
        return accountsById[id]
    }
    
    static func with(email: String) -> Account? {
        return accountsByLowercasedEmail[email.lowercased()]
    }
}
