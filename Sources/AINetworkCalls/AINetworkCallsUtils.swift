//
//  NetworkHelperUtils.swift
//  Story Crafter
//
//  Created by Alexy Ibrahim on 6/6/20.
//  Copyright © 2020 Alexy Ibrahim. All rights reserved.
//

import UIKit
import Network

internal class AINetworkCallsUtils: NSObject {
    static let shared = AINetworkCallsUtils()
    
    let monitor = NWPathMonitor()
    static var connectionExists: Bool! = true
    static var isExpensive: Bool! = false
    
    private final class func initNetworkStatus() {
        AINetworkCallsUtils.shared.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                AINetworkCallsUtils.connectionExists = true
            } else {
                AINetworkCallsUtils.connectionExists = false
            }

            AINetworkCallsUtils.isExpensive = path.isExpensive
        }
        
        let queue = DispatchQueue(label: "Monitor")
        AINetworkCallsUtils.shared.monitor.start(queue: queue)
    }
    
    internal class func canProceedWithRequest(displayWarning: Bool = false) -> Bool {
        if !(AINetworkCallsUtils.connectionExists) {
            if displayWarning {
                let viewController: UIViewController? = self.topMostWindowController()
                let alertViewController = UIAlertController(title: "Warning", message: "No internet connection available", preferredStyle: .alert)
                
                alertViewController.addAction(UIAlertAction(title: "okay", style: .cancel) { action in
                    alertViewController.dismiss(animated: true, completion: nil)
                })
                
                viewController?.present(alertViewController, animated: true, completion: nil)
            }
            
            return false
        }
        
        return true
    }
    
    private final class func topMostWindowController()->UIViewController? {
        
        var topController = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController // UIApplication.shared.keyWindow?.rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    internal final class func displayNativeMessage(_ message: String, withTitle title:String? = nil, okayCallback: (() -> ())? = nil, yesCallback: (() -> ())? = nil, noCallback: (() -> ())? = nil, dismissDelay: Float? = nil, dismissDelayCallback: (() -> ())? = nil) {
        let viewController: UIViewController? = self.topMostWindowController()
        
        let title:String? = ((title != nil) ? title!:nil)
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if (noCallback != nil) || (yesCallback != nil) {
            alertViewController.addAction(UIAlertAction(title: "No", style: .default) { action in
                alertViewController.dismiss(animated: true, completion: nil)
                if let noCallback = noCallback {
                    noCallback()
                }
            })
            alertViewController.addAction(UIAlertAction(title: "Yes", style: .default) { action in

                alertViewController.dismiss(animated: true, completion: nil)
                if let yesCallback = yesCallback {
                    yesCallback()
                }
            })
        } else {
            alertViewController.addAction(UIAlertAction(title: "Ok", style: .cancel) { action in
                alertViewController.dismiss(animated: true, completion: nil)
                if let okayCallback = okayCallback {
                    okayCallback()
                }
            })
        }
        
        
        alertViewController.popoverPresentationController?.sourceView = AINetworkCallsUtils.topMostWindowController()?.view
        alertViewController.popoverPresentationController?.sourceRect = AINetworkCallsUtils.topMostWindowController()?.view.bounds ?? CGRect.zero
        
        viewController?.present(alertViewController, animated: true, completion: nil)
    }

}

extension Dictionary where Key == String, Value == Any {
    
    mutating func safelyAdd(_ value: Any?, forKey key: String) {
        guard let value = value else {
            return
        }
        
        self[key] = value
    }
}
