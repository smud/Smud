//
// FightCommands.swift
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

public class Fight {
    private var smud: Smud
    private var creatures = [Creature]()
    
    init(smud: Smud) {
        self.smud = smud
    }
    
    public func start(attacker: Creature, victim: Creature) {
        let shouldScheduleNextRound = creatures.isEmpty
        
        guard attacker.room == victim.room else {
            print("WARNING: trying to attack a creature in another room")
            return
        }
        
        attacker.fighting = victim
        if victim.fighting == nil {
            victim.fighting = attacker
        }
        
        if !creatures.contains(attacker) {
            creatures.append(attacker)
        }
        if !creatures.contains(victim) {
            creatures.append(victim)
        }
        
        if shouldScheduleNextRound {
            nextRound()
        }
    }
    
    var i = 0
    func nextRound() {
        print("\nFight round \(i)")
        i += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + smud.combatRoundInterval) {
            guard !self.creatures.isEmpty else { return }
            
            self.nextRound()
        }
    }
}
