//
// DispatchCompatibility.swift
//
// This source file is part of the SMUD open source project
//
// Copyright (c) 2016 SMUD project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SMUD project authors
//

#if os(Linux)
import Dispatch

class DispatchTime {
    static func now() -> dispatch_time_t {
        return dispatch_time(DISPATCH_TIME_NOW, 0)
    }
}

class DispatchQueue {
   static var main: dispatch_queue_t {
       return dispatch_get_main_queue()
   }
}

extension dispatch_queue_t {
    func asyncAfter(deadline: dispatch_time_t, _ block: ()->()) {
        dispatch_after(deadline, self, block)
    }
}
#endif

