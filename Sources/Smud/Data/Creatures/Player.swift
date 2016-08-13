//
// Player.swift
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

class Player: Creature {
    var playerId: Int64?
    var accountId: Int64?
    
    override class var databaseTableName: String { return "players" }

    required init(row: Row) {
        playerId = row.value(named: "player_id")
        accountId = row.value(named: "account_id")
        super.init(row: row)
        name = (row.value(named: "name") as String).capitalized
    }
    
    override init() {
        super.init()
    }
    
    static func with(name: String) -> Player? {
        return DB.queue.inDatabase { db in
            Player.fetchOne(db, "SELECT * FROM players WHERE name = ?",
                            arguments: [name.lowercased()])
        }
    }
    
    static func namesWith(accountId: Int64) -> [String] {
        return DB.queue.inDatabase { db in
            String.fetchAll(db, "SELECT name FROM players WHERE account_id = ?",
                            arguments: [accountId])
        }.map { $0.capitalized }
    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["player_id": playerId,
                "account_id": accountId,
                "name": name.lowercased()]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        playerId = rowID
    }
}
