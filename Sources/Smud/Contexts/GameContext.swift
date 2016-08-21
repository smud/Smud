//
// GameContext.swift
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

final class GameContext: ConnectionContext {
    static var name = "game"
    
    func greet(connection: Connection) {
        connection.sendPrompt("> ")
    }
    
    func processResponse(args: Arguments, connection: Connection) throws -> ContextAction {
        
        guard let player = connection.player else {
            print("Connection doesn't have an associated player: \(connection.address)")
            return .retry(internalErrorMessage)
        }
        Commands.router.process(args: args,
                                player: player,
                                connection: connection,
                                unknownCommand: { context in
            connection.send("Unknown command: \(context.args.scanWord().unwrapOptional)")
        },
                                partialMatch: { context in
            connection.send("Warning! Part of your input was ignored: \(context.args.scanRestOfString().unwrapOptional)")
                                    
        })
        
        return .retry(nil)
    }
}
