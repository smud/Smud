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
    static var byPrimaryTag = [String: Area]()
    static var modifiedEntities = Set<Area>()
    
    var deleted = false

    var areaId: Int64? {
        didSet {
            //guard oldValue == nil else { fatalError() }
            //guard let areaId = areaId else { return }
            //Area.byAreaId[areaId] = self
        }
    }
    var primaryTag: String
    var name = ""

    static func with(primaryTag: String) -> Area? {
        return byPrimaryTag[primaryTag]
    }
    
    init(primaryTag: String) {
        self.primaryTag = primaryTag
        Area.byPrimaryTag[primaryTag] = self
    }
}

extension Area: Equatable {
    static func ==(lhs: Area, rhs: Area) -> Bool {
        return lhs.areaId == rhs.areaId
    }
}

extension Area: Hashable {
    var hashValue: Int { return areaId?.hashValue ?? 0 }
}
