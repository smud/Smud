//
// DB.swift
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

public class DB {
    typealias Players = Set<Player>

    var smud: Smud
    private var updating = false
    
    let serialSaveQueue = DispatchQueue(label: "Smud.SerialSaveQueue")

    // Areas
    let world = World()
    let definitions = Definitions()

    // Accounts
    var modifiedAccounts = Set<Account>()
    var nextAccountId: Int64 = 0
    var accountsByLowercasedEmail = [String: Account]()
    var accountsById = [Int64: Account]()
    
    // Players
    var modifiedPlayers = Set<Player>()
    var nextPlayerId: Int64 = 0
    var playersByLowercasedName = [String: Player]()
    var playersByAccountId = [Int64: Players]()

    init(smud: Smud) {
        self.smud = smud
    }
    
    // Call once
    func startUpdating() {
        assert(!updating)
        updating = true
        nextUpdate()
    }
    
    private func nextUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + smud.databaseUpdateInterval) {
            
            //print("Saving")
            do {
                try self.savePendingEntities()
            } catch {
                fatalError("While saving records to database: \(error)")
            }
            self.nextUpdate()
        }
    }
    
    func savePendingEntities() throws {
        try saveAccounts { count in
            if count > 0 { print("\(count) account(s) saved") }
        
            // Accounts need to be saved before players are saved.
            // Players depend on accountIds being assigned.
            try savePlayers { count in
                if count > 0 { print("\(count) player(s) saved") }
                
                try saveAreas { count in
                    if count > 0 { print("\(count) area(s) saved") }
                }
            }
        }
    }
}

struct DBError: Error, CustomStringConvertible {
    enum Kind: CustomStringConvertible {
        case inconsistentAccountFilename(actual: String, generated: String)
        case inconsistentPlayerFilename(actual: String, generated: String)
        
        var description: String {
            switch self {
            case let .inconsistentAccountFilename(actual, generated):
                return "Inconsistent account filename. Actual filename: '\(actual)', generated filename: '\(generated)'"
            case let .inconsistentPlayerFilename(actual, generated):
                return "Inconsistent player filename. Actual filename: '\(actual)', generated filename: '\(generated)'"
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
