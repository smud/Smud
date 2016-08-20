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
import GRDB

class Account: Record {
    var accountId: Int64?
    var email = ""
    
    override class var databaseTableName: String { return "accounts" }
    
    required init(row: Row) {
        accountId = row.value(named: "account_id")
        email = row.value(named: "email")
        super.init(row: row)
    }
    
    override init() {
        super.init()
    }
    
    func save() throws {
        try DB.queue.inDatabase { db in
            try self.save(db)
        }
    }
    
    static func with(email: String) -> Account? {
        return DB.queue.inDatabase { db in
            Account.fetchOne(db, "SELECT * FROM accounts WHERE email = ?",
                             arguments: [email])
        }
    }

    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["account_id": accountId,
                "email": email]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        accountId = rowID
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
