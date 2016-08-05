//
// Email.swift
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

#if os(OSX)
typealias RegularExpression = NSRegularExpression
#endif

class Email {
    static func isValidEmail(_ email: String) -> Bool {
        let regex = try! RegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,6}$",
            options: [.caseInsensitive])
        return regex.firstMatch(in: email, options: [],
            range: NSMakeRange(0, email.utf16.count)) != nil
    }
}
