//
// Scanner+Utils.swift
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

extension Scanner {
    #if os(OSX)
    func scanInt32() -> Int32? {
        var result: Int32 = 0
        return scanInt32(&result) ? result : nil
    }
    #endif

	@discardableResult
    func skipInt32() -> Bool {
        #if os(OSX)
        return scanInt32(nil)
        #else
        return scanInt() != nil
        #endif
    }
    
    #if os(OSX)
    func scanInteger() -> Int? {
        var result: Int = 0
        return scanInt(&result) ? result : nil
    }
    #endif
    
	@discardableResult
    func skipInteger() -> Bool {
        return scanInteger() != nil
    }
    
    #if os(OSX)
    func scanInt64() -> Int64? {
        var result: Int64 = 0
        return scanInt64(&result) ? result : nil
    }
    #else
    func scanInt64() -> Int64? {
        var result: Int64 = 0
        return scanLongLong(&result) ? result : nil
    }
    #endif
    
	@discardableResult
    func skipInt64() -> Bool {
        return scanInt64() != nil
    }
    
    func scanUInt64() -> UInt64? {
        var result: UInt64 = 0
        return scanUnsignedLongLong(&result) ? result : nil
    }
    
	@discardableResult
    func skipUInt64() -> Bool {
        return scanUInt64() != nil
    }
    
    func scanFloat() -> Float? {
        var result: Float = 0.0
        return scanFloat(&result) ? result : nil
    }
    
	@discardableResult
    func skipFloat() -> Bool {
        return scanFloat() != nil
    }
    
    func scanDouble() -> Double? {
        var result: Double = 0.0
        return scanDouble(&result) ? result : nil
    }
    
	@discardableResult
    func skipDouble() -> Bool {
        return scanDouble() != nil
    }
    
    #if os(OSX)
    func scanHexUInt32() -> UInt32? {
        var result: UInt32 = 0
        return scanHexInt32(&result) ? result : nil
    }
    #else
    func scanHexUInt32() -> UInt32? {
        var result: UInt32 = 0
        return scanHexInt(&result) ? result : nil
    }
    #endif
    
	@discardableResult
    func skipHexUInt32() -> Bool {
        return scanHexUInt32() != nil
    }
    
    #if os(OSX)
    func scanHexUInt64() -> UInt64? {
        var result: UInt64 = 0
        return scanHexInt64(&result) ? result : nil
    }
    #else
    func scanHexUInt64() -> UInt64? {
        var result: UInt64 = 0
        return scanHexLongLong(&result) ? result : nil
    }
    #endif
    
	@discardableResult
    func skipHexUInt64() -> Bool {
        return scanHexUInt64() != nil
    }
    
    func scanHexFloat() -> Float? {
        var result: Float = 0.0
        return scanHexFloat(&result) ? result : nil
    }
    
	@discardableResult
    func skipHexFloat() -> Bool {
        return scanHexFloat() != nil
    }
    
    func scanHexDouble() -> Double? {
        var result: Double = 0.0
        return scanHexDouble(&result) ? result : nil
    }
    
	@discardableResult
    func skipHexDouble() -> Bool {
        return scanHexDouble() != nil
    }
    
	@discardableResult
    func skipString(_ string: String) -> Bool {
        #if os(OSX)
        return scanString(string, into: nil)
        #else
        return scanString(string) != nil
        #endif
    }
    
    #if os(OSX)
    func scanCharactersFromSet(_ set: CharacterSet) -> String? {
        var result: NSString? = nil
		if scanCharacters(from: set, into: &result) {
            return result as? String
        }
        return nil
    }
    #endif
	
	@discardableResult
    func skipCharactersFromSet(_ set: CharacterSet) -> Bool {
		return scanCharactersFromSet(set) != nil
    }
    
    #if os(OSX)
    func scanUpToString(_ string: String) -> String? {
        var result: NSString? = nil
		if scanUpTo(string, into: &result) {
            return result as? String
        }
        return nil
    }
    #endif
	
    #if os(OSX)
	@discardableResult
    func skipUpToString(_ string: String) -> Bool {
        return scanUpTo(string, into: nil)
    }
    #else
	@discardableResult
    func skipUpToString(_ string: String) -> Bool {
        return scanUpTo(string) != nil
    }
    #endif
    
    #if os(OSX)
    func scanUpToCharactersFromSet(_ set: CharacterSet) -> String? {
        var result: NSString? = nil
		if scanUpToCharacters(from: set, into: &result) {
            return result as? String
        }
        return nil
    }
    #endif
    
    #if os(OSX)
	@discardableResult
    func skipUpToCharactersFromSet(_ set: CharacterSet) -> Bool {
		return scanUpToCharacters(from: set, into: nil)
    }
    #else
	@discardableResult
    func skipUpToCharactersFromSet(_ set: CharacterSet) -> Bool {
		return scanUpToCharactersFromSet(set) != nil
    }
    #endif
}
