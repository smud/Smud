//
// Room.swift
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

public class Room {
    public let prototype: Entity
    public var areaInstance: AreaInstance
    
    public var title: String
    
    init(prototype: Entity, instance: AreaInstance) {
        self.prototype = prototype
        self.areaInstance = instance
        
        title = prototype.value(named: "title")?.string ?? "No title"
    }
}
