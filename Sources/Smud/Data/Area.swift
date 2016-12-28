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

public class Area {
    public let id: String
    public var title: String
    public let smud: Smud
    public var instances = [Int: AreaInstance]()
    public var nextInstanceIndex = 1

    public init(id: String, prototype: AreaPrototype, smud: Smud) {
        self.id = id
        self.smud = smud
        
        let entity = prototype.entity
        title = entity.value(named: "title")?.string ?? "No title"
    }
}
