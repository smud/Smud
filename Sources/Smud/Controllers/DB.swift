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
//import GRDB

//class DB {
//    private static var updating = false
//    
//    static let serialSaveQueue = DispatchQueue(label: "Smud.SerialSaveQueue")
//    
//    static let queue: DatabaseQueue = {
//        var config = Configuration()
//        config.busyMode = .timeout(10) // Wait 10 seconds before throwing SQLITE_BUSY error
//        config.defaultTransactionKind = .deferred
//        config.trace = { print("  \($0)") }     // Prints all SQL statements
//        
//        let dbFilename = "Game/db.sqlite"
//        do {
//            return try DatabaseQueue(path: dbFilename, configuration: config)
//        } catch {
//            fatalError("Unable to open database '\(dbFilename)': \(error)")
//        }
//    }()
//    
//    static func loadWorldSync() {
//        let accounts = AccountRecord.loadAllEntitiesSync()
//        accounts.forEach { Account.addToIndexes(account: $0) }
//        print("  Loaded \(accounts.count) account(s)")
//        
//        let players = PlayerRecord.loadAllEntitiesSync()
//        players.forEach { Player.addToIndexes(player: $0) }
//        print("  Loaded \(players.count) player(s)")
//        
//        let areas = AreaRecord.loadAllEntitiesSync()
//        areas.forEach { Area.addToIndexes(area: $0) }
//        print("  Loaded \(areas.count) area(s)")
//    }
//    
//    // Call once
//    static func startUpdating() {
//        assert(!updating)
//        updating = true
//        nextUpdate()
//    }
//    
//    private static func nextUpdate() {
//        DispatchQueue.main.asyncAfter(deadline: .now() + databaseUpdateInterval) {
//            
//            //print("Saving")
//            savePendingEntitiesAsync {
//                nextUpdate()
//            }
//        }
//    }
//    
//    static func savePendingEntitiesAsync(completion: @escaping ()->() = {}) {
//        AccountRecord.saveModifiedEntitiesAsync { count in
//            if count > 0 { print("\(count) account(s) saved") }
//
//            // Accounts need to be saved before players are saved.
//            // Players depend on accountIds being assigned.
//            PlayerRecord.saveModifiedEntitiesAsync { count in
//                if count > 0 { print("\(count) player(s) saved") }
//                
//                AreaRecord.saveModifiedEntitiesAsync { count in
//                    if count > 0 { print("\(count) area(s) saved") }
//                    
//                    completion()
//                }
//            }
//        }
//    }
//}
//
//
//
