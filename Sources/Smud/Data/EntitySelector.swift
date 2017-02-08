//
// EntitySelector.swift
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

public enum EntitySelector {
    case link(Link)
    case pattern(EntityPattern)
    
    func matches(creature: Creature) -> Bool {
        switch self {
        case .link(let link):
            return link.matches(creature: creature)
        case .pattern(let pattern):
            return pattern.matches(creature: creature)
        }
    }
}
