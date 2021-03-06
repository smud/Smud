//
// FileUtils.swift
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

typealias FileEnumerationHandler = (_ filename: String, _ stop: inout Bool) throws -> ()

func enumerateFiles(atPath path: String, ignoreTemporaryFiles: Bool = true, handler: FileEnumerationHandler) rethrows {
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(atPath: path)
    
    var stop = false
    while let element = enumerator?.nextObject() as? String {
        if ignoreTemporaryFiles {
            guard !element.hasPrefix(".") else { continue }
            guard !element.hasSuffix("~") else { continue }
            guard !element.hasSuffix(".swp") else { continue }
        }
        try handler(element, &stop)
        if stop { break }
    }
}

func enumerateFiles(atPath path: String, withExtension ext: String, handler: FileEnumerationHandler) rethrows {
    
    let dotExt = "." + ext

    try enumerateFiles(atPath: path) { filename, stop in
        guard filename.hasSuffix(dotExt) else { return }
        try handler(filename, &stop)
    }
}

func enumerateFiles(atPath path: String, withExtensions extensions: [String], handler: FileEnumerationHandler) rethrows {
    
    let dotExtensions = extensions.map { "." + $0 }
    
    try enumerateFiles(atPath: path) { filename, stop in
        for dotExtension in dotExtensions {
            if filename.hasSuffix(dotExtension) {
                try handler(filename, &stop)
                return
            }
        }
    }
}
