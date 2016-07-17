//
// ItemPrototype.swift
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

struct ItemPrototype {
    var tags: [String]

    var name: String
    var synonyms: [String]

    var description: String
    var descriptionInRoom: String
    var legend: String
    var keywordsText: [String: String]
    
    var gender: Gender
    var plural: Bool
}
