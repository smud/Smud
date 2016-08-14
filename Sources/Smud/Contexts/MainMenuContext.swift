//
// MainMenuContext.swift
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

final class MainMenuContext: ConnectionContext {
    static var name = "mainMenu"
    
    func greet(connection: Connection) {
        guard let name = connection.player?.name else { return }
        connection.sendPrompt(
            "Welcome \(name)!\n" +
            "1. Play\n" +
            "0. Exit\n" +
            "What would you like to do? ")
    }
    
    func processResponse(args: Arguments, connection: Connection) -> ContextAction {
        guard let optionIndex = args.scanInt() else {
            return .retry("Please enter a number.")
        }
        switch optionIndex {
        case 1:
            return .next(GameContext())
        case 0:
            connection.send("Goodbye!")
            return .disconnect
        default:
            break
        }
        return .retry("Unknown option.")
    }
}
