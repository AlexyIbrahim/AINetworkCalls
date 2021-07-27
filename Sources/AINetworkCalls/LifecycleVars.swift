//
//  AppLifecycleVars.swift
//  Fibler2
//
//  Created by Alexy Ibrahim on 6/25/20.
//  Copyright © 2020 siegma. All rights reserved.
//

import UIKit

internal struct LifecycleVars {
    static var endpoints: [AIEndpoint] = [AIEndpoint]()
    
    static func endpointForKey(_ endpointKey: String) -> String? {
        return LifecycleVars.endpoints.first {
            $0.endpointKey == endpointKey
        }?.rawValue
    }
}
