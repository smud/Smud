//
// DB+Accounts.swift
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

public extension DB {
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
}
