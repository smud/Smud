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
    public let prototype: AreaPrototype
    public var title: String
    public var origin: Link?
    public let world: World
    public var instancesByIndex = [Int: AreaInstance]()
    public var nextInstanceIndex = 1

    public init(id: String, prototype: AreaPrototype, world: World) {
        self.id = id
        self.prototype = prototype
        self.world = world
        
        let entity = prototype.entity
        title = entity.value(named: "title")?.string ?? "No title"
        origin = entity.value(named: "origin")?.link
    }
    
    public func createInstance() -> AreaInstance {
        let index = findUnusedInstanceIndex()
        let instance = AreaInstance(area: self, index: index)
        instancesByIndex[index] = instance
        nextInstanceIndex = index + 1
        return instance
    }
    
    public func findUnusedInstanceIndex() -> Int {
        var index = nextInstanceIndex
        while nil != instancesByIndex[index] {
            index += 1
        }
        return index
    }
}

