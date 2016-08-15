//
// EditorCommands.swift
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

class EditorCommands {
    static func register(with router: CommandRouter) {
        router["area list"] = areaList
        router["area new"] = areaNew
    }
    
    static func areaList(context: CommandContext) -> CommandAction {
        context.connection.send("Area list")
        return .accept
    }
    
    static func areaNew(context: CommandContext) -> CommandAction {
        context.connection.send("Area new")
        return .accept
    }
}
