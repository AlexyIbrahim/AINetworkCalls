//
//  NetworkHelperUtils.swift
//  Story Crafter
//
//  Created by Alexy Ibrahim on 6/6/20.
//  Copyright © 2020 Alexy Ibrahim. All rights reserved.
//

import UIKit
import Network
import SwiftyJSON

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
    
    internal final class func displayMessage(_ message: String, withTitle title:String? = nil, okayCallback: (() -> ())? = nil) {
        let viewController: UIViewController? = self.topMostWindowController()
        
        let title:String? = ((title != nil) ? title!:nil)
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertViewController.addAction(UIAlertAction(title: "Okay", style: .cancel) { action in
            alertViewController.dismiss(animated: true, completion: nil)
            okayCallback?()
        })
        
        
        alertViewController.popoverPresentationController?.sourceView = AINetworkCallsUtils.topMostWindowController()?.view
        alertViewController.popoverPresentationController?.sourceRect = AINetworkCallsUtils.topMostWindowController()?.view.bounds ?? CGRect.zero
        
        viewController?.present(alertViewController, animated: true, completion: nil)
    }
    
    internal final class func decode<T> (model: T.Type, from json: JSON) -> T where T : Decodable {
//        print("json.stringValue: \(json.diction)")
        let jsonData = try? JSONSerialization.data(withJSONObject: json.dictionaryObject as Any, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)!
//        print("json string: \(jsonString)")
        
//        let encoder = JSONEncoder()
//        if let jsonData = try! encoder.encode(json.dictionaryObject) {
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print(jsonString)
//            }
//        }
        
        return AINetworkCallsUtils.decode(model: model, from: jsonString)
    }
    
    internal final class func decode<T> (model: T.Type, from dictionary: [String: String]) -> T where T : Decodable {
        
        let encoder = JSONEncoder()
        let jsonData = try! encoder.encode(dictionary)
        return AINetworkCallsUtils.decode(model: model, from: jsonData)
    }
    
    internal final class func decode<T> (model: T.Type, from string: String) -> T where T : Decodable {
        
        return AINetworkCallsUtils.decode(model: model, from: string.data(using: .utf8)!)
    }
    
    internal final class func decode<T> (model: T.Type, from data: Data) -> T where T : Decodable {
        let decoder = JSONDecoder()
        
        let myStruct = try! decoder.decode(model, from: data)
        return myStruct
    }
}

internal extension Dictionary where Key == String, Value == Any {
    mutating func safelyAdd(_ value: Any?, forKey key: String) {
        guard let value = value else {
            return
        }
        
        self[key] = value
    }
}
