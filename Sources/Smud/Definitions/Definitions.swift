//
// Definitions.swift
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

class Definitions {
    var itemFields = FieldDefinitions()
    var mobileFields = FieldDefinitions()
    var roomFields = FieldDefinitions()
    var enumerations = Enumerations()
    
    func registerRoomFields() throws {
        let d = roomFields
        try d.insert(name: "room", type: .tag, flags: .required)
        try d.insert(name: "title", type: .line, flags: .required)
        try d.insert(name: "description", type: .longText)
        
        try d.insert(name: "exit.north", type: .link, flags: .structureStart)
        try d.insert(name: "exit.east", type: .link, flags: .structureStart)
        try d.insert(name: "exit.south", type: .link, flags: .structureStart)
        try d.insert(name: "exit.west", type: .link, flags: .structureStart)
        try d.insert(name: "exit.up", type: .link, flags: .structureStart)
        try d.insert(name: "exit.down", type: .link, flags: .structureStart)
    }
}

