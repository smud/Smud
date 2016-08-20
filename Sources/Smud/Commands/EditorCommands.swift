//
// EditorCommands.swift
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

class EditorCommands {
    static func register(with router: CommandRouter) {
        router["area list"] = areaList
        router["area new"] = areaNew
        router["area delete"] = areaDelete
        router["area rename"] = areaRename
        router["area"] = area
        router["save"] = save
    }
    
    static func areaList(context: CommandContext) -> CommandAction {
        context.send("List of areas:")
        let areas = AreaManager.areas.map { k, v in "  \(v.name) #\(v.primaryTag)" }.joined(separator: "\n")
        context.send(areas.isEmpty ? "  none." : areas)
        return .accept
    }
    
    static func areaNew(context: CommandContext) throws -> CommandAction {
        let words = context.args.scanWords()
        let areaName = words.filter { !$0.hasPrefix("#") }.joined(separator: " ")
        let tags = words.filter { $0.hasPrefix("#") }.map { $0.droppingPrefix() }
        
        guard tags.count == 1 && !areaName.isEmpty else {
            context.send("Usage: area new #tag Short description ")
            return .accept
        }

        let area: Area
        do {
            area = try AreaManager.createArea(withPrimaryTag: tags.first!)
        } catch let error as AreaManagerError {
            context.send(error)
            return .accept
        }
        
        //area.extaTags = Set<String>(tags.dropFirst())
        area.name = areaName
        try area.scheduleForSaving()
        
        context.send("Area #\(area.primaryTag) created.")
        
        return .accept
    }
    
    static func areaDelete(context: CommandContext) throws -> CommandAction {
        guard let word = context.args.scanWord(), word.hasPrefix("#") else {
            context.send("Usage: area delete #tag")
            return .accept
        }
        let tag = word.droppingPrefix()
        let area: Area
        do {
            area = try AreaManager.deleteArea(withId: tag)
        } catch let error as AreaManagerError {
            context.send(error)
            return .accept
        }

        context.send("Area #\(area.primaryTag) deleted.")

        return .accept
    }
    
    static func areaRename(context: CommandContext) throws -> CommandAction {
        let areaRenameUsage = "Usage:\n" +
            " - Rename a tag and set a new description:\n" +
            "     area rename #old_tag #new_tag New description\n" +
            " - Rename only a tag:\n" +
            "     area rename #old_tag #new_tag\n" +
            " - Set a new description:\n" +
            "     area rename #tag New description"
        
        let words = context.args.scanWords()
        let areaName = words.filter { !$0.hasPrefix("#") }.joined(separator: " ")
        let tags = words.filter { $0.hasPrefix("#") }.map { $0.droppingPrefix() }

        if 1...2 ~= tags.count {
            let oldTag = tags[0]
            guard let area = AreaManager.areas[oldTag] else {
                context.send("Area tagged #\(oldTag) does not exist.")
                return .accept
            }
            guard tags.count != 1 || !areaName.isEmpty else {
                context.send(areaRenameUsage)
                return .accept
            }
            if tags.count == 2 {
                let newTag = tags[1]
                do {
                    try AreaManager.renameArea(oldTag: oldTag, newTag: newTag)
                    context.send("Area #\(oldTag) renamed to #\(newTag).")
                } catch let error as AreaManagerError {
                    context.send(error)
                }
            }
            if !areaName.isEmpty {
                area.name = areaName
                try area.scheduleForSaving()
                context.send("Area #\(area.primaryTag) description changed to: \(area.name)")
            }
            
        } else {
            context.send(areaRenameUsage)
        }
        return .accept
    }
    
    static func area(context: CommandContext) -> CommandAction {
        if let subcommand = context.args.scanWord() {
            context.send("Unknown subcommand: \(subcommand)")
        }
        context.send("Available subcommands: list, new")
        return .accept
    }
    
    static func save(context: CommandContext) throws -> CommandAction {
        context.send("Saving all areas.")
        try AreaManager.flush()
        return .accept
    }
}
