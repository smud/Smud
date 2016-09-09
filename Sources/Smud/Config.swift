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

// Database
let databaseUpdateInterval = 15.0
let databaseUpdateLeeway: DispatchTimeInterval? = nil

// Networking
let port: UInt16 = 4000
let maximumLineLengthBytes = 1024

// Character naming
let playerNameLength = 2...16
let playerNameAllowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz")
let playerNameInvalidCharactersMessage = "Name contains invalid characters. Allowed characters: a-z"

let internalErrorMessage =  "An internal error has occured, the developers have been notified. If the error persists, please contact the support."
