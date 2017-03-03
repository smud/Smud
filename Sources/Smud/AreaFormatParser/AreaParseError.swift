//
// AreaParseError.swift
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
import ScannerUtils

struct AreaParseError: Error, CustomStringConvertible {
    enum Kind: CustomStringConvertible {
        case unableToLoadFile(error: Error)
        case unterminatedComment
        case expectedSectionStart
        case expectedSectionName
        case expectedSectionEnd
        case unsupportedSectionType
        case flagsExpected
        case invalidFieldFlags
        case duplicateFieldDefinition
        case syntaxError
        case expectedFieldName
        case unsupportedEntityType
        case unknownFieldType
        case expectedNumber
        case duplicateField
        case expectedFieldSeparator
        case expectedDoubleQuote
        case unterminatedString
        case expectedEnumerationValue
        case invalidEnumerationValue
        case duplicateValue
        case structureCantStartFromThisField
        case unterminatedStructure
        case noCurrentArea
        case unknownEntityType
        case tagShouldStartWithHash
        case invalidTagFormat
        case linkShouldStartWithHash
        case invalidLinkFormat
        case areaPrototypeNotFound
        
        var description: String {
            switch self {
            case .unableToLoadFile(let error):
                #if CYGWIN
                return "unable to load file: \(error)"
                #else
                return "unable to load file: \(error.localizedDescription)"
                #endif
            case .unterminatedComment: return "unterminated comment found"
            case .expectedSectionStart: return "expected '['"
            case .expectedSectionName: return "expected section name terminated with ']'"
            case .expectedSectionEnd: return "expected ']'"
            case .unsupportedSectionType: return "unsupported section type"
            case .flagsExpected: return "flags expected"
            case .invalidFieldFlags: return "invalid field flags"
            case .duplicateFieldDefinition: return "duplicate field definition"
            case .syntaxError: return "syntax error"
            case .expectedFieldName: return "expected field name"
            case .unsupportedEntityType: return "unsupported entity type"
            case .unknownFieldType: return "unknown field type"
            case .expectedNumber: return "expected number"
            case .duplicateField: return "duplicate field"
            case .expectedFieldSeparator: return "expected field separator"
            case .expectedDoubleQuote: return "expected double quote"
            case .unterminatedString: return "unterminated string"
            case .expectedEnumerationValue: return "expected enumeration value"
            case .invalidEnumerationValue: return "invalid enumeration value"
            case .duplicateValue: return "duplicate value"
            case .structureCantStartFromThisField: return "structure can't start from this field"
            case .unterminatedStructure: return "unterminated structure"
            case .noCurrentArea: return "no current area to add entity to, please specify it using 'area' field above the entity definition"
            case .unknownEntityType: return "unknown entity type"
            case .tagShouldStartWithHash: return "tag should start with hash"
            case .invalidTagFormat: return "invalid tag format: tag should contain at least one alphanumeric value or underscore"
            case .linkShouldStartWithHash: return "link should start with hash"
            case .invalidLinkFormat: return "invalid link format"
            case .areaPrototypeNotFound: return "area prototype not found"
            }
        }
    }
    
    let kind: Kind
    let scanner: Scanner?
    
    var description: String {
        guard let scanner = scanner else {
            return kind.description
        }
        var result = "\(scanner.line()):\(scanner.column()): \(kind.description)."
        if !scanner.isAtEnd {
            result += " Offending line:\n" +
            "\(scanner.lineBeingParsed)"
        }
        return result
    }
    
    var localizedDescription: String {
        return description
    }
}
