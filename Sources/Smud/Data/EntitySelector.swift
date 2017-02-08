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

public class EntitySelector {
    public enum SelectorType {
        case link(Link)
        case pattern(EntityPattern)
    }
    
    public var startingIndex = 1
    public var count = 1
    public var type: SelectorType
    
    public init?(_ string: String) {
        let scanner = Scanner(string: string)
        while !scanner.isAtEnd {
            if let value = scanner.scanInteger() {
                if scanner.skipString(".") {
                    startingIndex = value
                } else if scanner.skipString("*") {
                    count = value
                }
            } else if let link = Link(scanFrom: scanner) {
                type = .link(link)
                return
            } else {
                let pattern = EntityPattern(scanFrom: scanner)
                type = .pattern(pattern)
                return
            }
        }
        return nil
    }

    func matches(creature: Creature) -> Bool {
        switch type {
        case .link(let link):
            return link.matches(creature: creature)
        case .pattern(let pattern):
            return pattern.matches(creature: creature)
        }
    }
}
