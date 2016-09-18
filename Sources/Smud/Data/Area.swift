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

final class Area: Modifiable {
    // Indexes
    fileprivate static var areasByPrimaryTag = [String: Area]()

    // Modifiable
    static var modifiedEntities = Set<Area>()
    var deleted = false

    var areaId: Int64?
    var primaryTag = ""
    var name = ""
    var roomTemplatesByTag = [String: Template]()
}

extension Area: Equatable {
    static func ==(lhs: Area, rhs: Area) -> Bool {
        return lhs.areaId == rhs.areaId
    }
}

extension Area: Hashable {
    var hashValue: Int { return areaId?.hashValue ?? 0 }
}

extension Area {
    static var all: LazyMapCollection<[String: Area], Area> {
        return Area.areasByPrimaryTag.values
    }
    
    static func addToIndexes(area: Area) {
        areasByPrimaryTag[area.primaryTag] = area
    }

    static func removeFromIndexes(area: Area) {
        areasByPrimaryTag.removeValue(forKey: area.primaryTag)
    }

    static func with(primaryTag: String) -> Area? {
        return areasByPrimaryTag[primaryTag]
    }
}

