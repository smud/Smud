//
// CommandRouter.swift
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

class CommandRouter {
    enum Action {
        case next
        case accept
    }
    
    typealias Handler = () throws -> Action
    typealias Path = (lowercasedCommand: String, handler: Handler)

    var paths = [Path]()

    func add(_ command: String, _ handler: Handler) {
        paths.append(Path(command.lowercased(), handler))
    }

    func process(line: String, unknownCommand: () -> (), partialMatch: () -> ()) {
        let scanner = Scanner(string: line)
        scanner.caseSensitive = false
        scanner.charactersToBeSkipped = CharacterSet.whitespacesAndNewlines

        let args = Arguments(scanner: scanner)

        guard let lowercasedCommand = args.scanWord()?.lowercased() else {
            unknownCommand()
            return
        }

        let originalScanLocation = scanner.scanLocation
        for path in paths {
            if path.lowercasedCommand.hasPrefix(lowercasedCommand) {
                do {
                    switch try path.handler() {
                    case .accept:
                        if !args.isAtEnd {
                            partialMatch()
                        }
                        return
                    case .next:
                        break
                    }
                } catch {
                    print("While processing '\(path.lowercasedCommand)': \(error)")
                }
            }
            scanner.scanLocation = originalScanLocation
        }
    }
}
