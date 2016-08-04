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

class Email {
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        #if os(OSX)
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
        #else
        return Predicate(format: "SELF MATCHES %@", argumentArray: [NSString(string: emailRegex)]).evaluate(with: NSString(string: email))
        #endif
    }
}
