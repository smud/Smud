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
    var entity: Account

    override class var databaseTableName: String { return "accounts" }
    
    required init(row: Row) {
        entity = Account()
        super.init(row: row)
        entity.accountId = row.value(named: "account_id")
        entity.email = row.value(named: "email")
    }
    
    required init(entity: Account) {
        self.entity = entity
        super.init()
    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["account_id": entity.accountId,
                "email": entity.email]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        entity.accountId = rowID
    }
}
