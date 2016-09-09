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

final class ChooseAccountContext: ConnectionContext {
    static var name = "chooseAccount"
    
    func greet(connection: Connection) {
        connection.sendPrompt("Please enter your email address: ")
    }
    
    func processResponse(args: Arguments, connection: Connection) throws -> ContextAction {
        guard let email = args.scanWord(),
            Email.isValidEmail(email) else { return .retry("Invalid email address.") }
        
        if let account = Account.with(email: email) {
            connection.account = account
            return .next(PlayerNameContext())
        }
        
        var account = Account(email: email)
        account.modified = true
        connection.account = account
        
        connection.send("Confirmation email has been sent to your email address.")
        return .next(ConfirmationCodeContext())
    }
}
