//
//  AppDelegate.swift
//  Example
//
//  Created by Alexy Ibrahim on 8/23/20.
//  Copyright © 2020 Alexy Ibrahim. All rights reserved.
//

import AINetworkCalls
import UIKit

public extension Endpoint {
    static let main = Endpoint(rawValue: "https://postman-echo.com/")
    static let sandbox = Endpoint(rawValue: "https://dev.shelvz.com/MerchandiserServer/mvc")
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        AINetworkCalls.config.isDebug = true

        // 🌿 Optional request callback
        AINetworkCalls.setGlobalRequestCallback { request in
            print("request: \(String(describing: request.toJson()))")
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
