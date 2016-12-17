//
// AreaFormatParserUtils.swift
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

func structureName(fromFieldName name: String) -> String? {
    guard name.contains(".") else { return nil }
    return name.components(separatedBy: ".").first
}

func structureAndFieldName(_ fullName: String) -> (String, String) {
    guard fullName.contains(".") else { return ("", fullName) }
    
    let components = fullName.components(separatedBy: ".")
    guard components.count == 2 else { return ("", fullName) }
    return (components[0], components[1])
}

func appendIndex(toName name: String, index: Int) -> String {
    return "\(name)[\(index)]"
}
