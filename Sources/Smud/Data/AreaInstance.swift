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

public class AreaInstance {
    public let area: Area
    public let rooms = [String: Room]()
    
    public init(area: Area) {
        self.area = area
    }
}

//final class AreaInstance {
//    // Indexes
//    fileprivate static var areasByPrimaryTag = [String: Area]()
//
//    // Modifiable
//    static var modifiedEntities = Set<AreaInstance>()
//    var deleted = false
//
//    var areaId: Int64?
//    var primaryTag = ""
//    var name = ""
//    //var roomTemplates = TemplateCollection()
//    //var instances = [Int: AreaInstance]()
//    var nextInstanceIndex = 1
//}
//
//extension AreaInstance: Equatable {
//    static func ==(lhs: AreaInstance, rhs: AreaInstance) -> Bool {
//        return lhs.areaId == rhs.areaId
//    }
//}
//
//extension AreaInstance: Hashable {
//    var hashValue: Int { return areaId?.hashValue ?? 0 }
//}
//
//extension AreaInstance {
//    static var all: LazyMapCollection<[String: Area], Area> {
//        return AreaInstance.areasByPrimaryTag.values
//    }
//    
//    static func addToIndexes(area: AreaInstance) {
//        areasByPrimaryTag[area.primaryTag] = area
//    }
//
//    static func removeFromIndexes(area: AreaInstance) {
//        areasByPrimaryTag.removeValue(forKey: area.primaryTag)
//    }
//
//    static func with(primaryTag: String) -> AreaInstance? {
//        return areasByPrimaryTag[primaryTag]
//    }
//}

