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
import ConfigFile

public final class Player: Creature {
    public var playerId: Int64
    public var account: Account

    public var editedInstances = Set<AreaInstance>()

    public var filename: String {
        return name.lowercased()
    }
    
    public init(name: String, account: Account, world: World) {
        let smud = world.smud
        playerId = smud.db.createPlayerId()
        self.account = account
        super.init(name: name, world: world)
    }
    
    public override init(from: ConfigFile, world: World) throws {
        let smud = world.smud
        guard let playerId: Int64 = from["playerId"] else {
            throw PlayerError(kind: .noPlayerId)
        }
        self.playerId = playerId
        
        guard let accountId: Int64 = from["accountId"] else {
            throw PlayerError(kind: .noAccountId)
        }
        // Accounts are loaded before players, so this is safe to do
        guard let account = smud.db.account(id: accountId) else {
            throw PlayerError(kind: .accountNotFound(accountId: accountId))
        }
        self.account = account
        
        try super.init(from: from, world: world)
    }
    
    override func save(to: ConfigFile) {
        to["playerId"] = playerId
        to["accountId"] = account.accountId
        super.save(to: to)
    }
    
    public func scheduleForSaving() {
        world.smud.db.modifiedPlayers.insert(self)
    }
}

//extension Player: Equatable {
//    public static func ==(lhs: Player, rhs: Player) -> Bool {
//        return lhs.playerId == rhs.playerId
//    }
//}

extension Player: Hashable {
    public var hashValue: Int { return playerId.hashValue }
}

struct PlayerError: Error, CustomStringConvertible {
    enum Kind: CustomStringConvertible {
        case noPlayerId
        case noAccountId
        case accountNotFound(accountId: Int64)
        
        var description: String {
            switch self {
            case .noPlayerId:
                return "Attempt to initialize Plauer from ConfigFile with no playerId"
            case .noAccountId:
                return "Attempt to initialize Plauer from ConfigFile with no accountId"
            case .accountNotFound(let accountId):
                return "Account not found, id: \(accountId)"
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
