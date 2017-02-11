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
    public var name: String {
        didSet {
            // FIXME: duplicated in 3 places in this class
            self.nameKeywords = extractKeywords(from: self.name)
        }
    }
    public private(set) var nameKeywords: [String] = []
    
    public var gender: Gender = .male
    public var plural = false
    
    public var room: Room?
    public weak var fighting: Creature?
    
    public var pluginsData = [ObjectIdentifier: AnyObject]()
    
    public init(name: String, world: World) {
        self.name = name
        self.nameKeywords = extractKeywords(from: self.name)
        
        self.world = world
    }
    
    public init(from: ConfigFile, world: World) throws {
        guard let name: String = from["name"] else {
            throw CreatureError(kind: .noName)
        }
        self.name = name
        self.nameKeywords = extractKeywords(from: self.name)

        self.world = world
        
        if let genderString: String = from["gender"], let gender = Gender(rawValue: genderString) {
            self.gender = gender
        }
        
        if let plural: Bool = from["plural"] {
            self.plural = plural
        }
    }
    
//    public func hasKeyword(withPrefix prefix: String, caseInsensitive: Bool = false) -> Bool {
//        for keyword in nameKeywords {
//            if keyword.hasPrefix(prefix, caseInsensitive: caseInsensitive) { return true }
//        }
//        return false
//    }
    
    public func pluginData<Type>(id: ObjectIdentifier = ObjectIdentifier(Type.self)) -> Type where Type: PluginData, Type.Parent == Creature {
        if let data = pluginsData[id] as? Type {
            return data
        } else {
            let data = Type(parent: self)
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

extension Creature: Equatable {
    public static func ==(lhs: Creature, rhs: Creature) -> Bool {
        return lhs === rhs
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
