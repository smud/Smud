//
// Command.swift
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
import StringUtils

public class Command {
    typealias T = Command

    public struct Options: OptionSet {
        public var rawValue: Int
        public init(rawValue: Int) { self.rawValue = rawValue }

        /// Case sensitive comparision of commands.
        public static let caseSensitive = Options(rawValue: 1 << 2)
    }
    
    static let whitespaceAndNewline = CharacterSet.whitespacesAndNewlines

    let name: String
    let nameWords: [String]
    let options: Options
    
    public init(_ name: String, options: Options = []) {
        self.options = options
        self.name = name
        nameWords = name.components(separatedBy: T.whitespaceAndNewline)
    }
    	
    public func fetchFrom(_ scanner: Scanner, caseSensitive: Bool = false) -> String? {
        if nameWords.isEmpty {
            // This is "match all" rule
            return scanner.scanUpToCharacters(from: T.whitespaceAndNewline)
        }

        let caseSensitive = caseSensitive || options.contains(.caseSensitive)
        var userCommand = ""
        
        // Each word in nameWords should match a word (possibly abbreviated) from scanner
        for nameWord in nameWords {
            guard let word = scanner.scanUpToCharacters(from: T.whitespaceAndNewline) else {
                if nameWord.isEmpty {
                    // No user input should match empty command name in router
                    return userCommand
                }
                return nil
            }
            
            guard nameWord.hasPrefix(word, caseInsensitive: !caseSensitive) else {
                return nil
            }
                
            userCommand += word
        }
        return userCommand
    }
}
