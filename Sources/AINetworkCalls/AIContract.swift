//
//  AIContract.swift
//
//
//  Created by Alexy Ibrahim on 9/18/22.
//

import Alamofire
import Foundation
import Promises
import SwiftyJSON

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
	var aiUrl: AIUrl { get }
	var headers: HTTPHeaders? { get }
	var timeout: TimeInterval { get }
	var handleProgress: Bool? { get }
	var endpoint: String? { get }
	var multipartFormData: MultipartFormData? { get }
}

public extension AIServiceModule {
	var method: AIHTTPMethod { .get }
	var bodyParameters: Parameters? { nil }
	var timeout: TimeInterval { 60 }
	var queryParameters: Parameters? { nil }
	var headers: HTTPHeaders? { nil }
	var handleProgress: Bool? { nil }
	var endpoint: String? { nil }
	var multipartFormData: MultipartFormData? { nil }
}

public extension AIServiceModule {
	func execute<T: Decodable>(on dispatchQueue: DispatchQueue? = nil, objectType: T.Type) -> Promise<T> {
		AIContractInterceptor.request(on: dispatchQueue ?? backgroundQueue, contract: self, objectType: T.self)
	}
	
	func execute<T: Decodable>(on dispatchQueue: DispatchQueue? = nil) -> Promise<T> {
		AIContractInterceptor.request(on: dispatchQueue ?? backgroundQueue, contract: self, objectType: T.self)
	}
	
	func execute(on dispatchQueue: DispatchQueue? = nil) -> Promise<JSON> {
		AIContractInterceptor.request(on: dispatchQueue ?? backgroundQueue, contract: self, objectType: JSON.self)
	}
}

public class AIServiceWrapper {
	enum AIServiceWrapperError: Error {
		case invalidBaseUrl
		case invalidFullUrl
	}
	
	
	private(set) var serviceContract: AIServiceModule
	
	public init(module: AIServiceModule) {
		serviceContract = module
	}
}

extension AIServiceWrapper {
	var defaultParameters: Parameters? { return nil }
	
	var queryParameters: Parameters? { serviceContract.queryParameters }
	
	var bodyParameters: Parameters? { serviceContract.bodyParameters }
	
	var method: AIHTTPMethod { serviceContract.method }
	
	var timeout: TimeInterval { serviceContract.timeout }
	
	var headers: HTTPHeaders? { serviceContract.headers }
	
	var aiUrl: AIUrl { serviceContract.aiUrl }
	
	var handleProgress: Bool? { serviceContract.handleProgress }
	
	var endpoint: String? {
		if self.aiUrl.endpointExists, let endpoint = self.aiUrl.endpoint {
			return endpoint
		} else if let endpoint = serviceContract.endpoint {
			return endpoint
		}
		return nil
	}
	
	var baseUrl: BaseUrl? { serviceContract.aiUrl.baseUrl }
	
	var fullUrl: URL {
		var finalUrl: URL
		
		do {
			finalUrl = try constructFullUrl()
		} catch {
			fatalError("Error constructing URL: \(error)")
		}
		
		return finalUrl
	}
	
	private func constructFullUrl() throws -> URL {
		if self.aiUrl.isFullURL {
			guard let url = URL(string: self.aiUrl.fullURL) else {
				throw AIServiceWrapperError.invalidFullUrl
			}
			return url
		} else {
			if let baseUrlString = self.aiUrl.baseUrl?.rawValue, var baseUrl = URL(string: baseUrlString) {
				if let endpoint = self.endpoint {
					baseUrl.appendPathComponent("/\(endpoint)")
					guard let urlString = baseUrl.absoluteString.removingPercentEncoding, let url = URL(string: urlString) else {
						return baseUrl // Should never reach here due to preceding checks
					}
					return url
				} else {
					return baseUrl
				}
			} else {
				throw AIServiceWrapperError.invalidBaseUrl
			}
		}
	}
	
	
	public var jsonString: String? {
		guard let params = bodyParameters else { return nil }
		if #available(iOS 13.0, *) {
			if method != .get,
			   let data = try? JSONSerialization.data(withJSONObject: params, options: [.withoutEscapingSlashes, .sortedKeys])
			{
				return String(data: data, encoding: .utf8)
			}
		} else {
			// Fallback on earlier versions
		}
		return nil
	}
	
	var multipartFormData: MultipartFormData? { serviceContract.multipartFormData }
}

public typealias GenericSuccessClosure<T> = (_ fetchResult: T) -> Void
public typealias GenericErrorClosure = (_ fetchResult: JSON?, _ error: Error?) -> Void
public typealias VoidClosure = () -> Void
private let backgroundQueue: DispatchQueue = .global(qos: .background)

public class AIContractInterceptor {
	public final class func request<T: Decodable>(wrapper: AIServiceWrapper, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) {
		AINetworkCalls.manager.sessionConfiguration.timeoutIntervalForRequest = wrapper.timeout
		
		if wrapper.aiUrl.isFullURL {
			_ = AINetworkCalls.request(httpMethod: wrapper.method,
									   fullPath: wrapper.fullUrl.absoluteString,
									   headers: wrapper.headers,
									   urlEncoding: nil,
									   jsonEncoding: nil,
									   queryParameters: wrapper.queryParameters,
									   bodyParameters: wrapper.bodyParameters,
									   multipartFormData: wrapper.multipartFormData,
									   displayWarnings: false,
									   handleProgress: wrapper.handleProgress,
									   successCallback: successCallback,
									   errorCallback: errorCallback)
		} else {
			if wrapper.aiUrl.baseUrlExists {
				if let baseUrl = wrapper.baseUrl {
					if let endpoint = wrapper.endpoint {
						_ = AINetworkCalls.request(httpMethod: wrapper.method,
												   baseUrl: baseUrl,
												   endpoint: endpoint,
												   headers: wrapper.headers,
												   urlEncoding: nil,
												   jsonEncoding: nil,
												   queryParameters: wrapper.queryParameters,
												   bodyParameters: wrapper.bodyParameters,
												   multipartFormData: wrapper.multipartFormData,
												   displayWarnings: false,
												   handleProgress: wrapper.handleProgress,
												   successCallback: successCallback,
												   errorCallback: errorCallback)
					} else {
						errorCallback?(nil, AIServiceWrapper.AIServiceWrapperError.invalidBaseUrl)
					}
				} else {
					errorCallback?(nil, AIServiceWrapper.AIServiceWrapperError.invalidBaseUrl)
				}
			} else {
				errorCallback?(nil, AIServiceWrapper.AIServiceWrapperError.invalidBaseUrl)
			}
		}
	}
	
	public final class func request<T: Decodable>(contract: AIServiceModule, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) {
		let wrapper = AIServiceWrapper(module: contract)
		AIContractInterceptor.request(wrapper: wrapper, successCallback: successCallback, errorCallback: errorCallback)
	}
	
	// Promises
	public final class func request<T: Decodable>(on dispatchQueue: DispatchQueue? = nil, wrapper: AIServiceWrapper, objectType _: T.Type) -> Promise<T> {
		return Promise(on: dispatchQueue ?? .promises) { valueCallback, errorCallback in
			AIContractInterceptor.request(wrapper: wrapper, successCallback: { fetchResult in
				valueCallback(fetchResult)
			}, errorCallback: { _, error in
				if let error = error {
					errorCallback(error)
				}
			})
		}
	}
	
	public final class func request<T: Decodable>(on dispatchQueue: DispatchQueue? = nil, contract: AIServiceModule, objectType _: T.Type) -> Promise<T> {
		return Promise(on: dispatchQueue ?? .promises) { valueCallback, errorCallback in
			let wrapper = AIServiceWrapper(module: contract)
			AIContractInterceptor.request(wrapper: wrapper, successCallback: { fetchResult in
				valueCallback(fetchResult)
			}, errorCallback: { _, error in
				if let error = error {
					errorCallback(error)
				}
			})
		}
	}
}
