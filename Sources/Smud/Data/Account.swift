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

class Account {
    typealias PlayerLowercasedNames = LazyMapCollection<[String: Player], String>
    typealias PlayerNames = LazyMapCollection<PlayerLowercasedNames, String>
    
    static var byLowercasedEmail = [String: Account]()
    static var byAccountId = [Int64: Account]()
    static var modifiedAccounts = Set<Account>()

    //var isDeleted = false
    var accountId: Int64?
    var email: String

    var playersByLowercasedName = [String: Player]()
    
    var playerNames: PlayerNames {
        return playersByLowercasedName.keys.map { $0.capitalized }
    }
    
    var modified = false {
        didSet {
            switch modified {
            case true: Account.modifiedAccounts.insert(self)
            case false: Account.modifiedAccounts.remove(self)
            }
        }
    }
    
    static func with(accountId: Int64) -> Account? {
        return byAccountId[accountId]
    }
    
    static func with(email: String) -> Account? {
        return byLowercasedEmail[email.lowercased()]
    }
    
    init(email: String) {
        self.email = email
        Account.byLowercasedEmail[email.lowercased()] = self
    }
}

extension Account: Equatable {
    static func ==(lhs: Account, rhs: Account) -> Bool {
        return lhs.accountId == rhs.accountId
    }
}

extension Account: Hashable {
    var hashValue: Int { return accountId?.hashValue ?? 0 }
}
