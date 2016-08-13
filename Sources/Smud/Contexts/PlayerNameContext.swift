//
// PlayerNameContext.swift
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

final class PlayerNameContext: ConnectionContext {
    static var name = "playerName"
    
    func greet(connection: Connection) {
        defer { connection.sendPrompt("Please choose a name for your character: ") }
        
        guard let accountId = connection.account?.accountId else { return }
        let playerNames = Player.namesWith(accountId: accountId)
        guard !playerNames.isEmpty else { return }
        
        connection.send("Your characters:  ")
        for (index, name) in playerNames.sorted().enumerated() {
            connection.send("  \(index + 1). \(name)")
        }
    }

    func processResponse(args: Arguments, connection: Connection) throws -> ContextAction {
        guard let lowercasedName = args.scanWord()?.lowercased() else {
            return .retry(nil)
        }
        
        let badCharacters = playerNameAllowedCharacters.inverted
        guard lowercasedName.rangeOfCharacter(from: badCharacters) == nil else {
            return .retry(playerNameInvalidCharactersMessage)
        }
        
        let name = lowercasedName.capitalized
        let nameLength = name.characters.count
        guard nameLength >= playerNameLength.lowerBound else {
            return .retry("Character name is too short")
        }
        guard nameLength <= playerNameLength.upperBound else {
            return .retry("Character name is too long")
        }
        
        if let player = Player.with(name: name) {
            guard player.accountId == connection.account?.accountId else {
                return .retry("Character named '\(name)' already exists. Please choose a different name.")
            }
            connection.player = player
        } else {
            let player = Player()
            player.accountId = connection.account?.accountId
            player.name = name
            try player.save()
            connection.player = player
        }
        
        return .next(MainMenuContext())
    }
}
