//
// ConnectionContextBuilder.swift
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

class ConnectionContextBuilder {
    static var contextTypesByName: [String: ConnectionContext.Type] = [:]
    
    static func registerContexts() {
        register(contextType: ChooseAccountContext.self)
        register(contextType: ConfirmationCodeContext.self)
        register(contextType: MainMenuContext.self)
        register(contextType: PlayerNameContext.self)
    }
    
    static func register(contextType: ConnectionContext.Type) {
        contextTypesByName[contextType.name] = contextType
    }
    
    static func createContext(named name: String) -> ConnectionContext? {
        guard let type = contextTypesByName[name] else { return nil }
        return type.self.init()
    }
}
