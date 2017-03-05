//
// AreaMapElement.swift
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

public struct AreaMapRange {
    public var from: AreaMapPosition
    public var to: AreaMapPosition

    public init(_ position: AreaMapPosition) {
        self.from = position
        self.to = position
    }

    public init(from: AreaMapPosition, to: AreaMapPosition) {
        self.from = from
        self.to = to
    }

    public var size: AreaMapPosition {
        return to - from + AreaMapPosition(1, 1, 1)
    }

    public func size(axis: AreaMapPosition.Axis) -> Int {
        return to.get(axis: axis) - from.get(axis: axis) + 1
    }

    public mutating func expand(with position: AreaMapPosition) {
        self.from = lowerBound(self.from, position)
        self.to = upperBound(self.to, position)
    }

    public func expanded(with position: AreaMapPosition) -> AreaMapRange {
        return AreaMapRange(from: lowerBound(self.from, position), to: upperBound(self.to, position))
    }

    public mutating func unite(with range: AreaMapRange) {
        self.from = lowerBound(self.from, range.from)
        self.to = upperBound(self.to, range.to)
    }

    public func united(with range: AreaMapRange) -> AreaMapRange {
        return AreaMapRange(from: lowerBound(self.from, range.from), to: upperBound(self.to, range.to))
    }

    public mutating func shift(by offset: AreaMapPosition) {
        self.from += offset
        self.to += offset
    }

    public func shifted(by offset: AreaMapPosition) -> AreaMapRange {
        return AreaMapRange(from: self.from + offset, to: self.to + offset)
    }
}
