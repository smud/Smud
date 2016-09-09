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

class PlayerRecord: Record {
    var playerId: Int64?
    var accountId: Int64
    var name: String

    override class var databaseTableName: String { return "players" }
    
    required init(row: Row) {
        playerId = row.value(named: "player_id")
        accountId = row.value(named: "account_id")
        name = row.value(named: "name")
        super.init(row: row)
    }
    
    init(entity: Player) {
        playerId = entity.playerId
        guard let entityAccountId = entity.account.accountId else {
            fatalError("Player has no account while being saved")
        }
        accountId = entityAccountId
        name = entity.name
        super.init()
    }

    func createEntity() -> Player {
        guard let account = Account.with(accountId: accountId) else {
            fatalError("Player has no account while being created")
        }
        let player = Player(name: name, account: account)
        player.name = name
        return player
    }
    
    static func loadAllRecordsSync() -> [Player] {
        let records = DB.queue.inDatabase { db in
            PlayerRecord.fetchAll(db)
        }
        var result = [Player]()
        result.reserveCapacity(records.count)
        for record in records {
            let entity = record.createEntity()
            result.append(entity)
        }
        return result
    }
    
    static func saveModifiedRecordsAsync(completion: @escaping (_ count: Int)->() = {_ in}) {
        guard !Player.modifiedPlayers.isEmpty else {
            completion(0)
            return
        }
        
        let records = Player.modifiedPlayers.map {
            return PlayerRecord(entity: $0)
        }
        Player.modifiedPlayers.removeAll(keepingCapacity: true)
        
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
        return ["player_id": playerId,
                "account_id": accountId,
                "name": name.lowercased()]
    }
    
    override func didInsert(with rowID: Int64, for column: String?) {
        guard let player = Player.with(name: name) else {
            fatalError("Error while updating players index")
        }
        playerId = rowID
        player.playerId = rowID
    }
}
