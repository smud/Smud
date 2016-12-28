//
// World.swift
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

public class World {
    public let smud: Smud
    public var areasById = [String: Area]()
    
    public init(smud: Smud) {
        self.smud = smud
    }
    
    public subscript(id: String) -> Area? {
        get {
            return areasById[id]
        }
        set {
            if let area = newValue {
                areasById[id] = area
            } else {
                areasById.removeValue(forKey: id)
            }
        }
    }
    
}
