//
//  AreaMapRange.swift
//  DemoMUD
//
//  Created by Anton Karandeev on 29/01/2017.
//
//

import Foundation

struct AreaMapRange {
    var from: AreaMapPosition
    var to: AreaMapPosition

    init(_ position: AreaMapPosition) {
        self.from = position
        self.to = position
    }

    init (from: AreaMapPosition, to: AreaMapPosition) {
        self.from = from
        self.to = to
    }

    mutating func expand(with position: AreaMapPosition) {
        self.from = lowerBound(self.from, position)
        self.to = upperBound(self.to, position)
    }

    func expanded(with position: AreaMapPosition) -> AreaMapRange {
        return AreaMapRange(from: lowerBound(self.from, position), to: upperBound(self.to, position))
    }

    mutating func unite(with range: AreaMapRange) {
        self.from = lowerBound(self.from, range.from)
        self.to = upperBound(self.to, range.to)
    }

    func united(with range: AreaMapRange) -> AreaMapRange {
        return AreaMapRange(from: lowerBound(self.from, range.from), to: upperBound(self.to, range.to))
    }

    mutating func shift(by offset: AreaMapPosition) {
        self.from += offset
        self.to += offset
    }

    func shifted(by offset: AreaMapPosition) -> AreaMapRange {
        return AreaMapRange(from: self.from + offset, to: self.to + offset)
    }
}
