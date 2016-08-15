//
// String+Utils.swift
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

extension String {
    public func hasPrefix(_ prefix: String, caseInsensitive: Bool) -> Bool {
        if caseInsensitive {
            return nil != self.range(of: prefix, options: [.caseInsensitive, .anchored])
        }
        return hasPrefix(prefix)
    }
}
