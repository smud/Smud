//
// Tag.swift
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

public class Tag: CustomStringConvertible {
    var area: String?
    var object: String
    var instance: Int?
    
    var isQualified: Bool { return area != nil || instance != nil }
    
    init?(_ text: String) {
        guard text.hasPrefix("#") else { return nil }
        
        let elements = text.droppingPrefix().components(separatedBy: ":")
        guard 1...2 ~= elements.count else { return nil }
        
        if elements.count == 2 {
            guard let instance = Int(elements[1]) else { return nil }
            self.instance = instance
        }
        
        var path = elements[0].components(separatedBy: ".")
        guard 1...2 ~= path.count else { return nil }
        
        guard let object = path.popLast(), !object.isEmpty else { return nil }
        self.object = object
        
        if let area = path.popLast() {
            if area.isEmpty { return nil }
            self.area = area
        }
    }
    
    public var description: String {
        var result = "#"
        if let area = area {
            result += "\(area)."
        }
        result += object
        if let instance = self.instance {
            result += ":\(instance)"
        }
        return result
    }
}
