//
//  File 2.swift
//  
//
//  Created by Alexy Ibrahim on 19/07/2021.
//

import Foundation

public struct AIHTTPMethod: RawRepresentable, Equatable, Hashable {
    /// `CONNECT` method.
//    public static let connect = AIHTTPMethod(rawValue: "CONNECT")
    /// `DELETE` method.
//    public static let delete = AIHTTPMethod(rawValue: "DELETE")
    /// `GET` method.
    public static let get = AIHTTPMethod(rawValue: "GET")
    /// `HEAD` method.
//    public static let head = AIHTTPMethod(rawValue: "HEAD")
    /// `OPTIONS` method.
//    public static let options = AIHTTPMethod(rawValue: "OPTIONS")
    /// `PATCH` method.
//    public static let patch = AIHTTPMethod(rawValue: "PATCH")
    /// `POST` method.
    public static let post = AIHTTPMethod(rawValue: "POST")
    /// `PUT` method.
    public static let put = AIHTTPMethod(rawValue: "PUT")
    /// `TRACE` method.
//    public static let trace = AIHTTPMethod(rawValue: "TRACE")

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

//public struct AIEndpoint: RawRepresentable, Equatable, Hashable {
//    public let rawValue: String
//
//    public init(rawValue: String) {
//        self.rawValue = rawValue
//    }
//}

public struct AIEndpoint: Equatable, Hashable {
    public let endpointKey: String
    public let rawValue: String

    public init(endpointKey:String, rawValue: String) {
        self.endpointKey = endpointKey
        self.rawValue = rawValue
    }
}
