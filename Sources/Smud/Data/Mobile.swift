//
// Mobile.swift
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

public class Mobile: Creature {
    public let prototype: Entity

    public var id: String
    public var home: Room?

    public var shortDescription: String
    
    public var health = 0

    public init(prototype: Entity, world: World) {
        self.prototype = prototype
    
        let id = prototype["mobile"]?.string ?? ""
        assert(id != "")
        self.id = id
        
        let name  = prototype["name"]?.string ?? "No name"
        shortDescription = prototype["short"]?.string ?? ""
        
        super.init(name: name, world: world)

    }
}
