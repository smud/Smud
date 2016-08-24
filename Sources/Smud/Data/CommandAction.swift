//
// CommandAction.swift
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

enum CommandAction {
    /// Accept the command, stop command matching. If part of user input was not processed by command handler, report it to user.
    case accept

    /// Send `usageText` to user, stop command matching.
    case showUsage(String)

    /// Skip this command, continue command matching.
    case next
}
