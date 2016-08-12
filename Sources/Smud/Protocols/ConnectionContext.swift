//
// CreateAccountContext.swift
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

protocol ConnectionContext {
    static var name: String { get }
    init()
    func greet(connection: Connection)
    func processResponse(args: Arguments, connection: Connection) throws -> ContextAction
}

extension ConnectionContext {
    subscript(name: String) -> ConnectionContext? {
        get {
            return ConnectionContextBuilder.createContext(named: name)
        }
    }
}
