//
//  File.swift
//
//
//  Created by Alexy Ibrahim on 9/18/22.
//

import Foundation
import Alamofire
import SwiftyJSON
import Promises


public typealias Headers = HTTPHeaders
public typealias Parameters = [String: Any]

public enum Module: String {
	case sandbox
	case staging
	case production
}



public protocol AIServiceModule {
	var method: AIHTTPMethod { get }
	var bodyParameters: Parameters? { get }
	var queryParameters: Parameters? { get }
	var aiEndPoint: AIEndPoint { get }
	var headers: HTTPHeaders? { get }
	var timeout: TimeInterval { get }
	var handleProgress: Bool? { get }
	func url(baseUrl: URL?) -> URL?
}

public extension AIServiceModule {
	var method: AIHTTPMethod { .get }
	var bodyParameters: Parameters? { nil }
	var timeout: TimeInterval { 60 }
	var queryParameters: Parameters? { nil }
	var headers: HTTPHeaders? { nil }
	var handleProgress: Bool? { nil }
}

extension AIServiceModule {
	
	public func url(baseUrl: URL?) -> URL? {
		
		var url = baseUrl
		
		url?.appendPathComponent("/\(aiEndPoint.function)")
		
		guard let urlString = url?.absoluteString.removingPercentEncoding else { return url }
		return URL(string: urlString)
	}
}

public class AIServiceWrapper {
	
	private (set) var serviceContract: AIServiceModule
	
	public init(module: AIServiceModule) {
		serviceContract = module
	}
}

extension AIServiceWrapper {
	
	var defaultParameters: Parameters? { return nil }
	
	var queryParameters: Parameters? { serviceContract.queryParameters }
	
	var bodyParameters: Parameters? { serviceContract.bodyParameters }
	
	var method: AIHTTPMethod { serviceContract.method }
	
	var url: URL? { serviceContract.url(baseUrl: serviceContract.url(baseUrl: .init(string: serviceContract.aiEndPoint.endpoint.rawValue))) }
	
	var timeout: TimeInterval { serviceContract.timeout }
	
	var headers: HTTPHeaders? { serviceContract.headers }
	
	var aiEndPoint: AIEndPoint { serviceContract.aiEndPoint }
	
	var handleProgress: Bool? { serviceContract.handleProgress }
	
	public var jsonString: String? {
		guard let params = bodyParameters else { return nil }
		if #available(iOS 13.0, *) {
			if method != .get,
			   let data = try? JSONSerialization.data(withJSONObject: params, options: [.withoutEscapingSlashes, .sortedKeys]) {
				return String(data: data, encoding: .utf8)
			}
		} else {
			// Fallback on earlier versions
		}
		return nil
	}
}

public typealias GenericSuccessClosure<T> = (_ fetchResult: T) -> Void
public typealias GenericErrorClosure = (_ fetchResult:JSON?, _ error:Error?) -> Void
public typealias VoidClosure = () -> Void

public class AIContractInterceptor {
	public final class func request<T: Decodable>(wrapper: AIServiceWrapper, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) {
		AINetworkCalls.manager.sessionConfiguration.timeoutIntervalForRequest = wrapper.timeout
		
		_ = AINetworkCalls.request(httpMethod: wrapper.method,
								   endpoint: wrapper.aiEndPoint.endpoint,
								   function: wrapper.aiEndPoint.function,
								   headers: wrapper.headers,
								   urlEncoding: nil,
								   jsonEncoding: nil,
								   queryParameters: wrapper.queryParameters,
								   bodyParameters: wrapper.bodyParameters,
								   displayWarnings: false,
								   handleProgress: wrapper.handleProgress,
								   successCallback: successCallback,
								   errorCallback: errorCallback)
	}
	
	public final class func request<T: Decodable>(contract: AIServiceModule, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) {
		let wrapper = AIServiceWrapper(module: contract)
		AIContractInterceptor.request(wrapper: wrapper, successCallback: successCallback, errorCallback: errorCallback)
	}
	
	public final class func request<T: Decodable>(contract: AIServiceModule, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> Promise<T> {
		return Promise { valueCallback, errorCallback in
			let wrapper = AIServiceWrapper(module: contract)
			AIContractInterceptor.request(wrapper: wrapper, successCallback: { fetchResult in
				valueCallback(fetchResult)
			}, errorCallback: { fetchResult, error in
				if let error = error {
					errorCallback(error)
				}
			})
		}
	}
	
	public final class func request<T: Decodable>(on dispatchQueue: DispatchQueue, contract: AIServiceModule, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> Promise<T> {
		return Promise(on: dispatchQueue, { valueCallback, errorCallback in
			let wrapper = AIServiceWrapper(module: contract)
			AIContractInterceptor.request(wrapper: wrapper, successCallback: { fetchResult in
				valueCallback(fetchResult)
			}, errorCallback: { fetchResult, error in
				if let error = error {
					errorCallback(error)
				}
			})
		})
	}
}
