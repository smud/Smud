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
import GRDB

class DB {
    static let queue: DatabaseQueue = {
        var config = Configuration()
        config.busyMode = .timeout(10) // Wait 10 seconds before throwing SQLITE_BUSY error
        config.defaultTransactionKind = .deferred
        config.trace = { print($0) }     // Prints all SQL statements
        
        let dbFilename = "Data/db.sqlite"
        do {
            return try DatabaseQueue(path: dbFilename, configuration: config)
        } catch {
            fatalError("Unable to open database '\(dbFilename)': \(error)")
        }
    }()
}



