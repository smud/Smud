//
// Smud.swift
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
import Dispatch

public class Smud: Config {
    // Configuration
    public var plugins: [SmudPlugin] = []

    public var isTerminated = false {
        didSet {
            guard isTerminated else { fatalError("Cannot cancel termination process") }
            guard oldValue == false else { return }
            flushQueueusAndTerminate()
        }
    }
    
    public var db: DB!
    var areaManager: AreaManager!
    
    override public init() {
        super.init()
        db = DB(smud: self)
        areaManager = AreaManager(smud: self)
    }
    
    public func run() throws {
        print("Registering area format definitions")
        try registerDefinitions()
        
        print("Loading world")
        try db.loadWorldPrototypes()

        print("Loading player accounts")
        try db.loadAccounts()
        
        print("Loading player files")
        try db.loadPlayers()
        
        print("Starting database updates")
        db.startUpdating()

        print("Initializing areas")
        areaManager.initializeAreas()
        
        print("Resetting areas")
        areaManager.resetAreas()
        
        print("Building area instance maps")
        areaManager.buildAreaMaps()
        
        print("Entering game loop")
        plugins.forEach { $0.willEnterGameLoop() }
        dispatchMain()
    }
    
    func registerDefinitions() throws {
        print("  areas")
        try db.definitions.registerAreaFields()
        print("  rooms")
        try db.definitions.registerRoomFields()
        print("  mobiles")
        try db.definitions.registerMobileFields()
    }
    
    private func flushQueueusAndTerminate() {
        DispatchQueue.main.async {
            exit(0)
        }
    }
}
