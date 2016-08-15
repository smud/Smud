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
    typealias Handler = (_ context: CommandContext) throws -> CommandAction
    typealias Path = (lowercasedCommand: String, handler: Handler)
    typealias UnknownCommandHandler = (_ context: CommandContext) -> ()
    typealias PartialMatchHandler = (_ context: CommandContext) -> ()
    
    var paths = [Path]()

    func add(_ command: String, _ handler: Handler) {
        paths.append(Path(command.lowercased(), handler))
    }
    
    subscript(_ command: String) -> Handler {
        get {
            fatalError("Not implemented")
        }
        set {
            add(command, newValue)
        }
    }

    func process(context: CommandContext, unknownCommand: UnknownCommandHandler, partialMatch: PartialMatchHandler) {
        let args = context.args
        guard let lowercasedCommand = args.scanWord()?.lowercased() else {
            unknownCommand(context)
            return
        }
        
        let scanner = context.args.scanner
        let originalScanLocation = scanner.scanLocation
        for path in paths {
            if path.lowercasedCommand.hasPrefix(lowercasedCommand) {
                do {
                    switch try path.handler(context) {
                    case .accept:
                        if !args.isAtEnd {
                            partialMatch(context)
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
        unknownCommand(context)
    }
}
