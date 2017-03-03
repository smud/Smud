//
// AreaPrototype.swift
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

public class AreaPrototype {
    public var entity = Entity()
    
    public var itemsById = [String: Entity]()
    public var mobilesById = [String: Entity]()
    public var roomsById = [String: Entity]()
}

