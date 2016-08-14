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
        
        return .retry(nil)
    }
}
