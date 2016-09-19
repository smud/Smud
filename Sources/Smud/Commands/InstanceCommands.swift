//
// InstanceCommands.swift
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

class InstanceCommands {
    static func register(with router: CommandRouter) {
        router["instance list"] = instanceList
        router["instance new"] = instanceNew
        router["instance"] = instance
    }

    static func instanceList(context: CommandContext) -> CommandAction {
        let tag = context.args.scanTag()
        
        guard let area = context.findArea(tag: tag) else { return .accept }

        context.send("List of #\(area.primaryTag) instances:")
        let instances = area.instances.keys
            .sorted()
            .map { String($0) }
            .joined(separator: ", ")
        context.send(instances.isEmpty ? "  none." : instances)

        return .accept
    }
    
    static func instanceNew(context: CommandContext) throws -> CommandAction {
        guard let tag = context.args.scanTag(), tag.area == nil else {
            return .showUsage("Usage: instance new #area:instance\n" +
                "Instance number is optional.")
        }
        let areaTag = tag.object
        
        guard let area = Area.with(primaryTag: areaTag) else {
            context.send("Area tagged #\(areaTag) does not exist.")
            return .accept
        }

        var chosenIndex: Int
        
        if let index = tag.instance {
            guard nil == area.instances[index] else {
                context.send("Instance tagged \(tag) already exists.")
                return .accept
            }
            chosenIndex = index
            if chosenIndex == area.nextInstanceIndex {
                area.nextInstanceIndex += 1
            }
        } else {
            // Find next free slot
            chosenIndex = area.nextInstanceIndex
            while nil != area.instances[chosenIndex] {
                chosenIndex += 1
            }
            area.nextInstanceIndex = chosenIndex + 1
        }
        
        let instance = AreaInstance(area: area)
        
        area.instances[chosenIndex] = instance
        context.send("Instance #\(tag.object):\(chosenIndex) created.")
        
        return .accept
    }
    
    static func instance(context: CommandContext) -> CommandAction {
        var result = ""
        if let subcommand = context.args.scanWord() {
            result += "Unknown subcommand: \(subcommand)\n"
        }
        result += "Available subcommands: list new"
        return .showUsage(result)
    }
}
