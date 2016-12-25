//
// DB+World.swift
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

public extension DB {
    func loadWorld() throws {
        let parser = AreaFormatParser(world: smud.db.world, definitions: smud.db.definitions)
        
        let dotExtensions = smud.areaFileExtensions.map { ".\($0)" }
        var areaFileCount = 0
        var counters = [Int](repeating: 0, count: smud.areaFileExtensions.count)
        try enumerateFiles(atPath: smud.areasDirectory) { filename, stop in
            
            guard let extensionIndex  = dotExtensions.index(where: { filename.hasSuffix($0) }) else {
                return
            }
            
            print("  \(filename)")
            
            let directory = URL(fileURLWithPath: smud.areasDirectory, isDirectory: true)
            let fullName = directory.appendingPathComponent(filename, isDirectory: false).relativePath
            try parser.load(filename: fullName)
            
            counters[extensionIndex] += 1
            areaFileCount += 1
        }
        
        print("  \(areaFileCount) area file(s), in particular:")
        for (i, ext) in smud.areaFileExtensions.enumerated()
                where counters[i] > 0 {
            print("    \(counters[i]) \(ext) file(s)")
        }
    }
    
    func saveWorld(completion: (_ count: Int) throws->()) throws {
        try completion(0)
    }
}