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

public class Config {
    // Database
    public static let databaseUpdateInterval = 15.0
    public static let databaseUpdateLeeway: DispatchTimeInterval? = nil

    // Networking
    public static let port: UInt16 = 4000
    public static let maximumLineLengthBytes = 1024

    // Character naming
    public static let playerNameLength = 2...16
    public static let playerNameAllowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
    public static let playerNameInvalidCharactersMessage = "Name contains invalid characters. Allowed characters: a-z"

    public static let internalErrorMessage =  "An internal error has occured, the developers have been notified. If the error persists, please contact the support."
}
