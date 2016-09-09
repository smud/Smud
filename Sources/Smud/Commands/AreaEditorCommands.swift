//
// AreaEditorCommands.swift
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

class AreaEditorCommands {
    static func register(with router: CommandRouter) {
//        router["area list"] = areaList
//        router["area new"] = areaNew
//        router["area delete"] = areaDelete
//        router["area rename"] = areaRename
//        router["area"] = area
    }
    
//    static func areaList(context: CommandContext) -> CommandAction {
//        context.send("List of areas:")
//        let areas = AreaManager.areas.map { k, v in "  \(v.name) #\(v.primaryTag)" }.joined(separator: "\n")
//        context.send(areas.isEmpty ? "  none." : areas)
//        return .accept
//    }
//    
//    static func areaNew(context: CommandContext) throws -> CommandAction {
//        guard let tag = context.args.scanTag(), !tag.isQualified,
//            let areaName = context.args.scanRestOfString(), !areaName.isEmpty else {
//                return .showUsage("Usage: area new #tag Short description")
//        }
//
//        let area: Area
//        do {
//            area = try AreaManager.createArea(withPrimaryTag: tag.object, name: areaName)
//        } catch let error as AreaManagerError {
//            context.send(error)
//            return .accept
//        }
//        
//        context.send("Area #\(area.primaryTag) created.")
//        return .accept
//    }
//    
//    static func areaDelete(context: CommandContext) throws -> CommandAction {
//        guard let tag = context.args.scanTag(), !tag.isQualified else {
//            return .showUsage("Usage: area delete #tag")
//        }
//        let area: Area
//        do {
//            area = try AreaManager.deleteArea(withPrimaryTag: tag.object)
//        } catch let error as AreaManagerError {
//            context.send(error)
//            return .accept
//        }
//
//        context.send("Area #\(area.primaryTag) deleted.")
//        return .accept
//    }
//    
//    static func areaRename(context: CommandContext) throws -> CommandAction {
//        let areaRenameUsage = "Usage:\n" +
//            " - Rename a tag and set a new description:\n" +
//            "     area rename #old_tag #new_tag New description\n" +
//            " - Rename only a tag:\n" +
//            "     area rename #old_tag #new_tag\n" +
//            " - Set a new description:\n" +
//            "     area rename #tag New description"
//        
//        guard let oldTag = context.args.scanTag(), !oldTag.isQualified else {
//            return .showUsage(areaRenameUsage)
//        }
//
//        var newTag: Tag?
//        if let tag = context.args.scanTag() {
//            if !tag.isQualified {
//                context.send(areaRenameUsage)
//                return .accept
//            }
//            newTag = tag
//        }
//        
//        let areaName = context.args.scanRestOfString()
//        
//        guard let area = AreaManager.areas[oldTag.object] else {
//            context.send("Area tagged \(oldTag) does not exist.")
//            return .accept
//        }
//        guard newTag != nil || areaName != nil else {
//            context.send(areaRenameUsage)
//            return .accept
//        }
//        if let newTag = newTag {
//            do {
//                try AreaManager.renameArea(oldTag: oldTag.object, newTag: newTag.object)
//                context.send("Area \(oldTag) renamed to \(newTag).")
//            } catch let error as AreaManagerError {
//                context.send(error)
//            }
//        }
//        if let areaName = areaName {
//            area.name = areaName
//            try area.save()
//            context.send("Area #\(area.primaryTag) description changed to: \(area.name)")
//        }
//            
//        return .accept
//    }
//    
//    static func area(context: CommandContext) -> CommandAction {
//        var result = ""
//        if let subcommand = context.args.scanWord() {
//            result += "Unknown subcommand: \(subcommand)\n"
//        }
//        result += "Available subcommands: delete, list, new, rename"
//        return .showUsage(result)
//    }
}
