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
        connection.sendPrompt("Please choose a name for your character: ")
    }

    func processResponse(args: Arguments, connection: Connection) -> ContextAction {
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
        
        let player = Player()
        player.name = name
        connection.player = player
        
        return .next(MainMenuContext())
    }
}
