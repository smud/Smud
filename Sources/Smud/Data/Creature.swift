//
// Creature.swift
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
import ConfigFile

public class Creature {
    public let world: World
    public var name: String
    
    public var gender: Gender = .male
    public var plural = false
    
    public var room: Room?
    
    public var pluginsData = [ObjectIdentifier: AnyObject]()
    
    public init(name: String, world: World) {
        self.name = name
        self.world = world
    }
    
    public init(from: ConfigFile, world: World) throws {
        guard let name: String = from["name"] else {
            throw CreatureError(kind: .noName)
        }
        self.name = name
        self.world = world
        
        if let genderString: String = from["gender"], let gender = Gender(rawValue: genderString) {
            self.gender = gender
        }
        
        if let plural: Bool = from["plural"] {
            self.plural = plural
        }
    }
    
    public func pluginData<Type>(id: ObjectIdentifier) -> Type where Type: PluginData {
        if let data = pluginsData[id] as? Type {
            return data
        } else {
            let data = Type()
            pluginsData[id] = data
            return data
        }
    }
    
    func save(to: ConfigFile) {
        to["name"] = name
        to["gender"] = gender.rawValue
        to["plural"] = plural
    }
}

struct CreatureError: Error, CustomStringConvertible {
    enum Kind: CustomStringConvertible {
        case noName
        
        var description: String {
            switch self {
            case .noName:
                return "Name not set in ConfigFile"
            }
        }
    }
    
    let kind: Kind
    
    var description: String {
        return kind.description
    }
    
    var localizedDescription: String {
        return description
    }
}
