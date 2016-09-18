//
// Template.swift
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

class Template {
    typealias Setter = (name: String, value: AreaFormatConvertible)
    
    var parentTemplateTags = [String]()
    
    private var settersOrdered = [Setter]()
    private var settersByName = [String: Setter]()
    
    func append(setter: Setter) {
        // TODO: detect duplicates
        settersOrdered.append(setter)
        settersByName[setter.name] = setter
    }
    
    func getSetter(named name: String) -> Setter? {
        return settersByName[name]
    }
}
