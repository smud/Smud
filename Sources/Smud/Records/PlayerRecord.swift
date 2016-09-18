//
// PlayerRecord.swift
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

class PlayerRecord: Record, ModifiablePersistable {
    var entity: Player
    
    override class var databaseTableName: String { return "players" }
    
    required init(row: Row) {
        entity = Player()
        
        super.init(row: row)
        
        entity.playerId = row.value(named: "player_id")
        let accountId: Int64 = row.value(named: "account_id")
        entity.account = Account.with(id: accountId)
        
        let lowercasedName: String = row.value(named: "name")
        entity.name = lowercasedName.capitalized
    }
    
    required init(entity: Player) {
        self.entity = entity
        super.init()
    }
    
    override var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["player_id": entity.playerId,
                "account_id": entity.account?.accountId,
                "name": entity.name.lowercased()]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        Player.removeFromIndexes(player: entity)
        entity.playerId = rowID
        Player.addToIndexes(player: entity)
    }
}
