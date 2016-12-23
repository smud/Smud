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
import ConfigFile

public class DB {
    typealias Players = Set<Player>

    var smud: Smud
    private var updating = false
    
    let serialSaveQueue = DispatchQueue(label: "Smud.SerialSaveQueue")

    var modifiedAccounts = Set<Account>()
    var nextAccountId: Int64 = 0
    var accountsByLowercasedEmail = [String: Account]()
    var accountsById = [Int64: Account]()
    
    var modifiedPlayers = Set<Player>()
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

    // MARK: - Accounts
    
    func loadAccounts() throws {
        var accountCount = 0
        try enumerateFiles(atPath: smud.accountsDirectory) { filename, stop in
            
            print("  \(filename)")
            
            let directory = URL(fileURLWithPath: smud.accountsDirectory, isDirectory: true)
            let fullName = directory.appendingPathComponent(filename, isDirectory: false).relativePath
            let configFile = try ConfigFile(fromFile: fullName)
            let account = try Account(from: configFile, smud: smud)
            
            guard account.filename == filename else {
                throw DBError(kind: .inconsistentAccountFilename(actual: filename, generated: account.filename))
            }
        
            addToIndexes(account: account)
            
            nextAccountId = max(account.accountId + 1, nextAccountId)

            accountCount += 1
        }

        print("  \(accountCount) account(s), next id: \(nextAccountId)")
    }
    
    func saveAccounts(completion: (_ count: Int) throws->()) throws {
        var count = 0
        if !modifiedAccounts.isEmpty {
            let directory = URL(fileURLWithPath: smud.accountsDirectory, isDirectory: true)
            try FileManager.default.createDirectory(atPath: directory.relativePath, withIntermediateDirectories: true, attributes: nil)
        
            for account in modifiedAccounts {
                let configFile = ConfigFile()
                account.save(to: configFile)
                let fullName = directory.appendingPathComponent(account.filename, isDirectory: false).relativePath
                
                try configFile.save(toFile: fullName, atomically: true)
                
                count += 1
            }
            modifiedAccounts.removeAll(keepingCapacity: true)
        }
        try completion(count)
    }
    
    public func createAccountId() -> Int64 {
        defer { nextAccountId += 1 }
        return nextAccountId
    }
    
    public func account(id: Int64) -> Account? {
        return accountsById[id]
    }
    
    public func account(email: String) -> Account? {
        return accountsByLowercasedEmail[email.lowercased()]
    }
    
    public func addToIndexes(account: Account) {
        accountsById[account.accountId] = account
        accountsByLowercasedEmail[account.email.lowercased()] = account
    }
    
    private func removeFromIndexes(account: Account) {
        accountsById.removeValue(forKey: account.accountId)
        accountsByLowercasedEmail.removeValue(forKey: account.email.lowercased())
    }

    // MARK: - Players
    
    func loadPlayers() throws {
        
    }
    
    func savePlayers(completion: (_ count: Int) throws->()) throws {
        
    }
    
    public func addToIndexes(player: Player) {
        if let accountId = player.account?.accountId {
            var v = playersByAccountId[accountId] ?? []
            v.insert(player)
            playersByAccountId[accountId] = v
        }
        playersByLowercasedName[player.name.lowercased()] = player
    }
    
    public func removeFromIndexes(player: Player) {
        if let accountId = player.account?.accountId {
            if var v = playersByAccountId[accountId] {
                v.remove(player)
                if v.isEmpty {
                    playersByAccountId.removeValue(forKey: accountId)
                } else {
                    playersByAccountId[accountId] = v
                }
            }
        }
        playersByLowercasedName.removeValue(forKey: player.name.lowercased())
    }
    
    public func player(name: String) -> Player? {
        return playersByLowercasedName[name.lowercased()]
    }
    
    public func players(accountId: Int64) -> Set<Player> {
        return playersByAccountId[accountId] ?? []
    }

    // MARK: - Areas
    
    func loadAreas() throws {
        
    }
    
    func saveAreas(completion: (_ count: Int) throws->()) throws {
        
    }
}

struct DBError: Error, CustomStringConvertible {
    enum Kind: CustomStringConvertible {
        case inconsistentAccountFilename(actual: String, generated: String)
        
        var description: String {
            switch self {
            case let .inconsistentAccountFilename(actual, generated):
                return "Inconsistent account filename. Actual filename: '\(actual)', generated filename: '\(generated)'"
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
