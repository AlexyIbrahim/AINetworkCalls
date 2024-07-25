//
//  AINetworkCallsConnection.swift
//
//
//  Created by Alexy Ibrahim on 12/18/22.
//

import Foundation
import Network
import UIKit

public extension AINetworkCalls {
//    static let shared = NetworKit()
    class Connection {
        private static var _monitor: AnyObject! // NWPathMonitor(requiredInterfaceType: .cellular)
        @available(iOS 12, *)
        fileprivate static var monitor: NWPathMonitor! {
            if _monitor == nil {
                _monitor = NWPathMonitor()
            }
            return (_monitor as! NWPathMonitor)
        }

        private static var _path: NWPath!
    }
}

// MARK: - public

public extension AINetworkCalls.Connection {
    // MARK: - properties

    static var connectionExists: Bool! {
        if AINetworkCalls.Connection._path.status == .satisfied {
            return true
        } else {
            return false
        }
    }

    static var isExpensive: Bool! {
        return AINetworkCalls.Connection._path.isExpensive
    }

    static var path: NWPath! {
        return AINetworkCalls.Connection._path
    }

    static var status: NWPath.Status! {
        return AINetworkCalls.Connection._path.status
    }

    // MARK: - methods

    final class func initNetworkStatus(callback: ((_ status: NWPath.Status) -> Void)? = nil) {
        AINetworkCalls.Connection.monitor.pathUpdateHandler = { path in
            AINetworkCalls.Connection._path = path

            // 🌿 callback
            guard let callback = callback else {
                return
            }
            DispatchQueue.main.async {
                callback(path.status)
            }
        }

        let queue = DispatchQueue(label: "Monitor")
        AINetworkCalls.Connection.monitor.start(queue: queue)
    }

    class func canProceedWithRequest(displayWarning: Bool = false) -> Bool {
        if !(AINetworkCalls.Connection.connectionExists) {
            if displayWarning {
                AINetworkCallsUtils.displayMessage("No internet connection available", withTitle: "Warning") {}
            }

            return false
        }

        return true
    }
}
