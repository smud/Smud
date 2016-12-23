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

public final class Player: Creature {
    public let smud: Smud
    public var playerId: Int64?
    public var account: Account?
    
    public init(smud: Smud) {
        self.smud = smud
    }
    
    public func scheduleForSaving() {
        smud.db.modifiedPlayers.insert(self)
    }
}

extension Player: Equatable {
    public static func ==(lhs: Player, rhs: Player) -> Bool {
        return lhs.playerId == rhs.playerId
    }
}

extension Player: Hashable {
    public var hashValue: Int { return playerId?.hashValue ?? 0 }
}
