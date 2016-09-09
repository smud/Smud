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

class AccountRecord: Record {
    var accountId: Int64?
    var email: String

    override class var databaseTableName: String { return "accounts" }
    
    required init(row: Row) {
        accountId = row.value(named: "account_id")
        email = row.value(named: "email")
        super.init(row: row)
    }
    
    init(entity: Account) {
        accountId = entity.accountId
        email = entity.email
        super.init()
    }
    
    func createEntity() -> Account {
        let account = Account(email: email)
        account.accountId = accountId
        return account
    }
    
    static func loadAllEntitiesSync() -> [Account] {
        let records = DB.queue.inDatabase { db in
            AccountRecord.fetchAll(db)
        }
        var result = [Account]()
        result.reserveCapacity(records.count)
        for record in records {
            let entity = record.createEntity()
            result.append(entity)
        }
        return result
    }
    
    static func saveModifiedEntitiesAsync(completion: @escaping (_ count: Int)->() = {_ in}) {
        guard !Account.modifiedAccounts.isEmpty else {
            completion(0)
            return
        }
        
        let records = Account.modifiedAccounts.map {
            return AccountRecord(entity: $0)
        }
        Account.modifiedAccounts.removeAll(keepingCapacity: true)

        DB.serialSaveQueue.async {
            do {
                try DB.queue.inTransaction { db in
                    for record in records {
                        try record.save(db)
                    }
                    return .commit
                }
            } catch {
                fatalError("While saving records to database: \(error)")
            }
            DispatchQueue.main.async {
                completion(records.count)
            }
        }
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
