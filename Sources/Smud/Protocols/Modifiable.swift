//
// Modifiable.swift
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

//public protocol Modifiable: class, Hashable {
//    static var modifiedEntities: Set<Self> { get set }
//    var deleted: Bool { get set }
//    var modified: Bool { get set }
//}
//
//public extension Modifiable {
//    var modified: Bool {
//        get { return Self.modifiedEntities.contains(self) }
//        set {
//            switch newValue {
//            case true: Self.modifiedEntities.insert(self)
//            case false: Self.modifiedEntities.remove(self)
//            }
//        }
//    }
//}
