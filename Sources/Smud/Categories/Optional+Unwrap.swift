//
// Optional+Unwrap.swift
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

extension Optional {
    /// Removes `Optional()` when printing optionals.
    /// ```swift
    /// var x: String? = "text"
    /// var y: String?
    /// print("\(x), \(y)")
    /// print("\(x.unwrapOptional), \(y.unwrapOptional")
    /// ```
    /// Results in:
    /// ```
    /// Optional("text"), nil
    /// text, nil
    /// ```
    public var unwrapOptional: String {
        if let v = self {
            return "\(v)"
        }
        return "nil"
    }
}
