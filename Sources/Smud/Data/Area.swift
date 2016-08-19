//
// Area.swift
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

class Area {
    typealias RoomsByTag = [String: Room]
        
    var id: String
    var tags: Set<String> = []
    var name = ""
    
    //var roomTemplates
    var roomPrototypes = RoomsByTag()
    var instances = [Int: RoomsByTag]()
    
    init(id: String) {
        self.id = id
    }
}
