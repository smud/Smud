//
// Point.swift
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

struct AreaMapPosition: Hashable, Equatable {
    var x: Int
    var y: Int
    var plane: Int

    init(_ x: Int = 0, _ y: Int = 0, _ plane: Int = 0) {
        self.x = x
        self.y = y
        self.plane = plane
    }
    
    func adjustedBy(x: Int) -> AreaMapPosition {
        return AreaMapPosition(self.x + x, y, plane)
    }

    func adjustedBy(y: Int) -> AreaMapPosition {
        return AreaMapPosition(x, self.y + y, plane)
    }
    
    func adjustedBy(plane: Int) -> AreaMapPosition {
        return AreaMapPosition(x, y, self.plane + plane)
    }
    
    static func ==(lhs: AreaMapPosition, rhs: AreaMapPosition) -> Bool {
        return lhs.plane == rhs.plane &&
            lhs.x == rhs.x && lhs.y == rhs.y
    }

    public var hashValue: Int {
        // Smallest collision being x = -46272 and y = 46016
        let prime = 92821
        var result = prime &+ x
        result = prime &* result &+ y
        result = prime &* result &+ plane
        return result
    }
}
