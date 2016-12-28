//
// Mobile.swift
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

public class Mobile: Creature {
    public var tags: [String] = []
    
    public var synonyms: [String] = []
    
    public var description = ""
    public var descriptionInRoom = ""
    public var keywordsText: [String: String] = [:]
    
    public var health = 0

}
