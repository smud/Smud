//
// AreaInstance.swift
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

class AreaInstance {
    var roomsByTag = [String: Room]()
    
    init(area: Area) {
        createRooms(templates: area.roomTemplates)
    }
    
    func createRooms(templates: TemplateCollection) {
        let sortedTemplates = templates.byTag.sorted(by: { $0.key < $1.key })
        for pair in sortedTemplates {
            let template = pair.value

            createRoom(template: template)
        }
    }
    
    func createRoom(template: Template) {
        let room = Room()
        room.name = "Unnamed room"
        roomsByTag[template.primaryTag] = room
    }
}
