//
// EventBase.swift
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
import CEvent

let evFeatureET = Int32(EV_FEATURE_ET.rawValue)
let evFeatureO1 = Int32(EV_FEATURE_O1.rawValue)
let evFeatureFDS = Int32(EV_FEATURE_FDS.rawValue)

class EventBase {
    let eventBase: OpaquePointer?
    
    init?() {
        guard let eventBase = event_base_new() else { return nil }
        self.eventBase = eventBase
    }
    
    deinit {
        event_base_free(eventBase)
    }
        
    func getMethod() -> String {
        return String(cString: event_base_get_method(eventBase))
    }
    
    func getFeatures() -> Int32 {
        return event_base_get_features(eventBase)
    }
}
