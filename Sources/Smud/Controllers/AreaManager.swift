//
// AreaManager.swift
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

class AreaManager {
    let smud: Smud
    let world: World
    
    init(smud: Smud) {
        self.smud = smud
        world = smud.db.world
    }
    
    func initializeAreas() {
        smud.db.worldPrototypes.areaPrototypesById.forEach {
                id, areaPrototype in
            let area = Area(id: id, prototype: areaPrototype, world: world)
            smud.db.world.areasById[id] = area
        }
    }
    
    func resetAreas() {
        world.areasById.forEach { id, area in
            reset(id: id, area: area)
        }
    }
    
    func buildAreaMaps() {
        world.areasById.forEach { _, area in
            area.instancesByIndex.forEach { _, instance in
                instance.buildMap()
            }
        }
    }
    
    func reset(id: String, area: Area) {
        // If area doesn't have any instances yet, create first instance
        let instance: AreaInstance
        if area.instancesByIndex.isEmpty {
            instance = area.createInstance()
            area.instancesByIndex[instance.index] = instance
        } else {
            instance = area.instancesByIndex.first!.value
        }
    }
}
