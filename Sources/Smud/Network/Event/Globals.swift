//
// Globals.swift
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
import CEvent

func eventGetVersion() -> String {
    return String(cString: event_get_version())
}

func eventGetSupportedMethods() -> [String] {
    guard var pointer = event_get_supported_methods() else { return [] }
    var strings: [String] = []
    while let cString = pointer.pointee {
        strings.append(String(cString: cString))
        pointer += 1
    }
    return strings
}
