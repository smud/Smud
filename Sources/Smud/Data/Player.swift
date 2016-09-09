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
    private static var byLowercasedName = [String: Player]()
    static var modifiedEntities = Set<Player>()

    var playerId: Int64?
    //var accountId: Int64?
    var account: Account

    init(name: String, account: Account) {
        self.account = account
        super.init()
        self.name = name
        let lowercasedName = name.lowercased()
        Player.byLowercasedName[lowercasedName] = self
        account.playersByLowercasedName[lowercasedName] = self
    }

    static func with(name: String) -> Player? {
        return byLowercasedName[name.lowercased()]
    }
}

extension Player: Equatable {
    static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.playerId == rhs.playerId
    }
}

extension Player: Hashable {
    var hashValue: Int { return playerId?.hashValue ?? 0 }
}
