//
// SystemError.swift
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

struct SystemError: ErrorProtocol, CustomStringConvertible, CustomDebugStringConvertible {
    let errorNumber: Int32
    var text: String
    
    init(_ text: String = "") {
        self.errorNumber = errno
        self.text = text
    }
    
    init(errno: Int32, text: String) {
        self.errorNumber = errno
        self.text = text
    }
    
    func printError() {
        print("\(description)")
    }
    
    var description: String {
        return String(cString: strerror(errorNumber))
    }
    
    var debugDescription: String {
        if text.isEmpty {
            return "[\(errorNumber)] \(description)"
        } else {
            return "\(text): [\(errorNumber)] \(description)"
        }
    }
}
