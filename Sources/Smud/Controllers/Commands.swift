//
// Commands.swift
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

class Commands {
    static let router = CommandRouter()
    
    static func register() {
        InfoCommands.register(with: router)
        AdminCommands.register(with: router)
        InstanceCommands.register(with: router)
        RoomEditorCommands.register(with: router)
        AreaEditorCommands.register(with: router)
    }
}
