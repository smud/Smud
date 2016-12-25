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
    
    func resetAreas() {
        //world.areas.forEach { id, area in
        //    reset(id: id, area: area)
        //}
    }
    
    //func reset(id: String, area: Area) {
        
    //}
}
