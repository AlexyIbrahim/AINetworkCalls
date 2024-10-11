//
//  GetResponseModel.swift
//  Example
//
//  Created by Alexy Ibrahim on 27/07/2021.
//  Copyright © 2021 Alexy Ibrahim. All rights reserved.
//

import Foundation

// MARK: - Welcome

struct GetResponseModel: Codable {
//    let headers: Headers
    let url: String
    let args: Args
}

// MARK: - Args

struct Args: Codable {
    let foo1, foo2: String
}

// MARK: - Headers

struct Headers: Codable {
    let host, xAmznTraceID, xForwardedPort, acceptEncoding: String
    let userAgent, xForwardedProto, acceptLanguage, ifNoneMatch: String
    let accept: String

    enum CodingKeys: String, CodingKey {
        case host
        case xAmznTraceID = "x-amzn-trace-id"
        case xForwardedPort = "x-forwarded-port"
        case acceptEncoding = "accept-encoding"
        case userAgent = "user-agent"
        case xForwardedProto = "x-forwarded-proto"
        case acceptLanguage = "accept-language"
        case ifNoneMatch = "if-none-match"
        case accept
    }
}
