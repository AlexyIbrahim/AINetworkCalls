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
	/// `MULTIPART` method.
	public static let multipart = AIHTTPMethod(rawValue: "MULTIPART")
	/// `TRACE` method.
	//    public static let trace = AIHTTPMethod(rawValue: "TRACE")
	
	public let rawValue: String
	
	public init(rawValue: String) {
		self.rawValue = rawValue
	}
}

public struct BaseUrl: RawRepresentable, Equatable, Hashable {
	public let rawValue: String
	
	public init(rawValue: String) {
		self.rawValue = rawValue
	}
}

public struct AIUrl {
	public let baseUrl: BaseUrl?
	public let endpoint: String?
	public var fullURL: String
	
	var isFullURL: Bool {
		return baseUrl == nil
	}
	
	var baseUrlExists: Bool {
		return baseUrl != nil
	}
	
	var endpointExists: Bool {
		return endpoint != nil
	}
	
	public init(baseUrl: BaseUrl, endpoint: String? = nil) {
		self.baseUrl = baseUrl
		self.endpoint = endpoint
		if let enpoint = endpoint {
			self.fullURL = baseUrl.rawValue + enpoint
		} else {
			self.fullURL = baseUrl.rawValue
		}
	}
	
	public init(fullURL: String) {
		self.fullURL = fullURL
		self.baseUrl = nil
		self.endpoint = nil
	}
}

public struct Config {
	public static var shared = Config()
	public var isDebug: Bool = false
	public var trimLongResponse: Bool = false
	public var longResponseCharLimit = 256
	public var handleProgress: Bool = false
	public var displayWarnings: Bool = false
}
