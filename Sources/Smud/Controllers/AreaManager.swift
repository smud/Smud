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
            let area = Area(id: id, prototype: areaPrototype, smud: smud)
            smud.db.world[id] = area
        }
    }
    
    func resetAreas() {
        world.areasById.forEach { id, area in
            reset(id: id, area: area)
        }
    }
    
    func reset(id: String, area: Area) {
//        let instance: AreaInstance
//        if !area.instances.isEmpty {
//            instance = area.instances.first
//        } else {
//            instance = AreaInstance()
//            area.instances
//        }
    }
}
