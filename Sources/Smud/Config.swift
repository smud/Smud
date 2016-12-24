//
// Config.swift
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

open class Config {
    // Database
    public var databaseUpdateInterval = 15.0
    public var databaseUpdateLeeway: DispatchTimeInterval? = nil

    // Networking
    public var port: UInt16 = 4000
    public var maximumLineLengthBytes = 1024

    // Character naming
    public var playerNameLength = 2...16
    public var playerNameAllowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
    public var playerNameInvalidCharactersMessage = "Name contains invalid characters. Allowed characters: a-z"

    public var internalErrorMessage =  "An internal error has occured, the developers have been notified. If the error persists, please contact the support."
    
    // Directories
    public var areasDirectory = "Data/Areas"
    public var areaFileExtensions = ["area", "rooms", "mobiles", "items"]
    public var accountsDirectory = "Live/Accounts"
    public var playersDirectory = "Live/Players"
}
