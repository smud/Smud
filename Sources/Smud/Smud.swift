//
// Smud.swift
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

public class Smud {
    // Configuration
    public var areasDirectory = "Data/Areas"
    public var areaFileExtensions = ["rooms", "mobiles", "items"]
    
    private let areas = Areas()
    private let definitions = Definitions()
    
    public init() {
        
    }
    
    public func run() throws {
        print("Registering area format definitions")
        try registerDefinitions()
        
        print("Loading area files")
        try loadAreas()
    }
    
    func registerDefinitions() throws {
        print("  rooms")
        try definitions.registerRoomFields()
    }
    
    func loadAreas() throws {
        let parser = AreaFormatParser(areas: areas, definitions: definitions)
        try enumerateFiles(atPath: areasDirectory, withExtensions: areaFileExtensions) { filename, stop in
            
            print("  \(filename)")
            
            let fullName = URL(fileURLWithPath: areasDirectory, isDirectory: true).appendingPathComponent(filename, isDirectory: false).relativePath
            try parser.load(filename: fullName)
        }
    }
}
