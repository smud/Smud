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
import ConfigFile

public final class Account {
    public let smud: Smud
    public var accountId: Int64
    public var email = ""
    
    public var filename: String {
        return "\(accountId)"
    }
    
    public init(smud: Smud) {
        self.smud = smud
        accountId = smud.db.createAccountId()
    }

    public init(from: ConfigFile, smud: Smud) throws {
        self.smud = smud
        guard let accountId: Int64 = from["accountId"] else {
            throw AccountError(kind: .noAccountId)
        }
        self.accountId = accountId
        
        email = from["email"] ?? ""
    }

    func save(to: ConfigFile) {
        to["accountId"] = accountId
        to["email"] = email
    }

    public func scheduleForSaving() {
        smud.db.modifiedAccounts.insert(self)
    }
}

extension Account: Equatable {
    public static func ==(lhs: Account, rhs: Account) -> Bool {
        //return lhs.accountId == rhs.accountId
        return lhs === rhs
    }
}

extension Account: Hashable {
    public var hashValue: Int { return accountId.hashValue }
}

struct AccountError: Error, CustomStringConvertible {
    enum Kind: CustomStringConvertible {
        case noAccountId
        
        var description: String {
            switch self {
            case .noAccountId:
                return "Attempt to initialize Account from ConfigFile with no accountId"
            }
        }
    }
    
    let kind: Kind
    
    var description: String {
        return kind.description
    }
    
    var localizedDescription: String {
        return description
    }
}
