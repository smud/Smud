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

class AccountRecord: Record, ModifiablePersistable {
    var accountId: Int64?
    var email: String

    override class var databaseTableName: String { return "accounts" }
    
    required init(row: Row) {
        accountId = row.value(named: "account_id")
        email = row.value(named: "email")
        super.init(row: row)
    }
    
    required init(entity: Account) {
        accountId = entity.accountId
        email = entity.email
        super.init()
    }
    
    func createEntity() -> Account {
        let account = Account(email: email)
        account.accountId = accountId
        return account
    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["account_id": accountId,
                "email": email]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        guard let account = Account.with(email: email) else {
            fatalError("Error while updating accounts index")
        }
        accountId = rowID
        account.accountId = rowID
    }
}
