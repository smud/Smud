//
// Link.swift
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

public class Link: CustomStringConvertible {
    public var parent: String?
    public var object: String
    public var instance: Int?
    
    public var isQualified: Bool { return parent != nil || instance != nil }
    
    public init?(_ text: String) {
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
        
        if let parent = path.popLast() {
            if parent.isEmpty { return nil }
            self.parent = parent
        }
    }
    
    public var description: String {
        var result = "#"
        if let parent = parent {
            result += "\(parent)."
        }
        result += object
        if let instance = self.instance {
            result += ":\(instance)"
        }
        return result
    }
}
