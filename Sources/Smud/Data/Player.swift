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

final class Player: Creature, Modifiable {
    typealias Players = Set<Player>

    // Indexes
    static var playersByLowercasedName = [String: Player]()
    static var playersByAccountId = [Int64: Players]()

    static var modifiedEntities = Set<Player>()
    var deleted = false
    
    var playerId: Int64?
    var account: Account?
}

extension Player: Equatable {
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.playerId == rhs.playerId
    }
}

extension Player: Hashable {
    var hashValue: Int { return playerId?.hashValue ?? 0 }
}

extension Player {
    static func addToIndexes(player: Player) {
        guard let accountId = player.account?.accountId else { fatalError() }
        
        playersByLowercasedName[player.name.lowercased()] = player
        playersByAccountId[accountId]?.insert(player)
    }
    
    static func removeFromIndexes(player: Player) {
        guard let accountId = player.account?.accountId else { fatalError() }
        
        playersByLowercasedName.removeValue(forKey: player.name.lowercased())
        let _ = playersByAccountId[accountId]?.remove(player)
    }
    
    static func with(name: String) -> Player? {
        return playersByLowercasedName[name.lowercased()]
    }
    
    static func with(accountId: Int64) -> Set<Player> {
        return playersByAccountId[accountId] ?? []
    }
}
