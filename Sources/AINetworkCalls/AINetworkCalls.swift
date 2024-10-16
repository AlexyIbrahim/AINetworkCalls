import Alamofire
import Foundation
import ProgressHUD
import SwiftyJSON
import UIKit

public struct AINetworkCallsRequestModel {
	private var _path: String?
	private var _method: AIHTTPMethod?
	private var _headers: HTTPHeaders?
	private var _parameters: [String: Any]?
	private var _body: [String: Any]?
	
	public var path: String? {
		return _path
	}
	
	public var method: AIHTTPMethod? {
		return _method
	}
	
	public var headers: HTTPHeaders? {
		return _headers
	}
	
	public var parameters: [String: Any]? {
		return _parameters
	}
	
	public var body: [String: Any]? {
		return _body
	}
	
	init(withPath path: String?, method: AIHTTPMethod? = nil, headers: HTTPHeaders? = nil, parameters: [String: Any]? = nil, body: [String: Any]? = nil) {
		_path = path
		_method = method
		_headers = headers
		_parameters = parameters
		_body = body
	}
	
	public func toJson() -> [String: Any] {
		var data = [String: Any]()
		data.safelyAdd(path, forKey: "path")
		data.safelyAdd(method, forKey: "method")
		data.safelyAdd(headers, forKey: "headers")
		data.safelyAdd(parameters, forKey: "parameters")
		data.safelyAdd(body, forKey: "body")
		
		return data
	}
}

public class AINetworkCalls: NSObject {
	private static var localManager: Alamofire.Session?
	
	public static func initManager(interceptor: RequestInterceptor? = nil) {
		localManager = Session(interceptor: interceptor)
	}
	
	static var manager: Alamofire.Session = {
		if let localManager = localManager {
			return localManager
		} else {
			localManager = Session()
			return localManager!
		}
	}()
	
	public static var config: Config {
		get { Config.shared }
		set { Config.shared = newValue }
	}
	
	static var globalRequestCallback: ((_ requestModel: AINetworkCallsRequestModel) -> Void)?
	private static var globalUploadRequestCallback: ((_ request: UploadRequest) -> Void)?
	private static var globalSuccessCallback: ((_ response: AFDataResponse<Any>, _ fetchResult: JSON) -> Void)?
	private static var glocalErrorCallBack: ((_ response: AFDataResponse<Any>, _ fetchResult: JSON?, _ error: Error?, _ errorStatusCode: Int) -> Void)?
	
	//    public final class func initWithEndpoints(_ endpoints: [AIEndpoint]) {
	//        LifecycleVars.endpoints = endpoints
	//    }
	//
	//    public final class func addEndpoints(_ endpoints: [AIEndpoint]) {
	//        LifecycleVars.endpoints.append(contentsOf: endpoints)
	//    }
	//
	//    public final class func endpoints() -> [AIEndpoint] {
	//        LifecycleVars.endpoints
	//    }
	
	final class func tidyFunction(_ function: String) -> String {
		let functionStr: String = (function.hasPrefix("/") ? function : "/\(function)")
		let modifiedFunctionStr = AINetworkCallsUtils.formatUrl(url: functionStr)
		return modifiedFunctionStr
		//        AINetworkCalls.manager.interceptor = RequestInterceptor()
	}
	
	final class func generateFullPath(baseUrl: BaseUrl, endpoint: String) -> String {
		return AINetworkCalls.generatePathFromFunction(endpoint: baseUrl.rawValue, function: endpoint)
	}
	
	final class func generatePathFromFunction(endpoint: String, function: String) -> String {
		let path = endpoint + tidyFunction(function)
		let modifiedPath = AINetworkCallsUtils.formatUrl(url: path)
		return modifiedPath
	}
}

// MARK: - Handling

extension AINetworkCalls {
	final class func handleRequest(_ requestModel: AINetworkCallsRequestModel, handleProgress: Bool? = nil) {
		if handleProgress ?? Config.shared.handleProgress {
			ProgressHUD.animate(nil, .activityIndicator, interaction: false)
		}
		globalRequestCallback?(requestModel)
	}
	
	/**
	 Handle Alamofire response
	 
	 - Author:
	 Alexy
	 */
	final class func handleResponse<T>(response: AFDataResponse<T>, displayWarnings _: Bool, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) where T: Decodable {
		switch response.result {
		case .success(let value):
			if handleProgress ?? Config.shared.handleProgress {
				ProgressHUD.dismiss()
			}
			
			var json: JSON?
			if T.self == JSON.self {
				json = value as? JSON
			} else if T.self == [String: Any].self {
				if let dict = value as? [String: Any] {
					json = JSON(dict)
				}
			} else {
				// T is a custom Decodable model
				if let data = response.data {
					do {
						json = try JSON(data: data)
					} catch {
						print("Error parsing data to JSON: \(error)")
					}
				} else {
					print("No response data available to create JSON")
				}
			}
			
			if Config.shared.isDebug {
				let url = response.request?.url?.absoluteString ?? "n/a"
				let method = response.request?.method?.rawValue ?? "n/a"
				let headers = response.request?.headers.dictionary ?? [:]
				let statusCode = response.response?.statusCode ?? 0
				var body: String? = nil
				if let jsonData = response.request?.httpBody {
					body = String(data: jsonData, encoding: .utf8)
				}
				print("------- \(T.self) ------- [Success]")
				print("--- Request")
				print("[\(method)] \(url)")
				print("--- Headers")
				print(headers.isEmpty ? "n/a" : "\(headers)")
				print("--- Body")
				print(body ?? "n/a")
				print("--- Response [\(statusCode)]")
				var responseString = json != nil ? "\(json!)" : "\(value)"
				if Config.shared.trimLongResponse {
					responseString = AINetworkCallsUtils.truncate(str: responseString, length: Config.shared.longResponseCharLimit)
				}
				print(responseString)
			}
			
			// 🌿 success callback
			if T.self == JSON.self {
				// Convert Any to SwiftyJSON.JSON
				successCallback?(json as! T)
			} else if T.self == [String: Any].self {
				if let dictionary = value as? [String: Any] {
					successCallback?(dictionary as! T)
				} else {
					errorCallback?(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert response to [String: Any]"]))
				}
			} else {
				// Assume T is Decodable
				successCallback?(value)
				//				do {
				//					let data = try JSONSerialization.data(withJSONObject: value, options: [])
				//					let decodedObject = try JSONDecoder().decode(T.self, from: data)
				//					successCallback?(decodedObject)
				//				} catch {
				//					errorCallback?(nil, error)
				//				}
			}
			
			// 🌿 global callback
			if let json = json {
				let anyResponse = AFDataResponse<Any>(
					request: response.request,
					response: response.response,
					data: response.data,
					metrics: response.metrics,
					serializationDuration: response.serializationDuration,
					result: response.result.map { $0 as Any }
				)
				AINetworkCalls.globalSuccessCallback?(anyResponse, json)
			}
		case .failure(let error):
			if handleProgress ?? Config.shared.handleProgress {
				AINetworkCalls.handleError(response.error, errorCode: response.response?.statusCode ?? 0)
			}
			
			var json: JSON?
			if let data = response.data {
				do {
					json = try JSON(data: data)
				} catch {
					print("Error parsing error data to JSON: \(error)")
				}
			} else {
				print("No response data available to create JSON")
			}
			
			if Config.shared.isDebug {
				let url = response.request?.url?.absoluteString ?? "n/a"
				let method = response.request?.method?.rawValue ?? "n/a"
				let headers = response.request?.headers.dictionary ?? [:]
				var body: String? = nil
				if let jsonData = response.request?.httpBody {
					body = String(data: jsonData, encoding: .utf8)
				}
				print("------- \(T.self) ------- [Failure]")
				print("--- Request")
				print("[\(method)] \(url)")
				print("--- Headers")
				print(headers.isEmpty ? "n/a" : "\(headers)")
				print("--- Body")
				print(body ?? "n/a")
				if let json = json {
					let statusCode = response.response?.statusCode ?? 0
					print("--- Response [\(statusCode)]")
					var responseString = "\(json)"
					if Config.shared.trimLongResponse {
						responseString = AINetworkCallsUtils.truncate(str: responseString, length: Config.shared.longResponseCharLimit)
					}
					print(responseString)
				}
			}
			
			// 🌿 callback
			if T.self == JSON.self {
				errorCallback?(json, error)
			} else if T.self == [String: Any].self {
				if let dictionary = json?.dictionaryObject as? T {
					errorCallback?(dictionary as? JSON, error)
				} else {
					errorCallback?(json, error)
				}
			} else {
				// Assume T is Decodable
				errorCallback?(json, error)
			}
			
			// 🌿 global error callback
			let anyResponse = AFDataResponse<Any>(
				request: response.request,
				response: response.response,
				data: response.data,
				metrics: response.metrics,
				serializationDuration: response.serializationDuration,
				result: .failure(error)
			)
			AINetworkCalls.glocalErrorCallBack?(anyResponse, json, error, response.response?.statusCode ?? 0)
		}
	}
	
	private final class func handleError(_ error: Error?, errorCode: Int? = nil, fetchResult _: [String: Any]? = nil) {
		switch errorCode {
		case URLError.Code.timedOut.rawValue:
			ProgressHUD.error("Request Timeout", interaction: false)
		case URLError.Code.cannotParseResponse.rawValue:
			ProgressHUD.error("Could not parse response", interaction: false)
		case URLError.Code.badServerResponse.rawValue:
			ProgressHUD.error("Server is temporarily unavailable", interaction: false)
		default:
			ProgressHUD.error(error?.localizedDescription, interaction: false)
		}
	}
}

// MARK: - Misc

public extension AINetworkCalls {
	final class func enableDebug() {
		Config.shared.isDebug = true
	}
	
	final class func disableDebug() {
		Config.shared.isDebug = false
	}
	
	// MARK: Callback methods
	
	final class func setGlobalRequestCallback(globalRequestCallback: @escaping ((_ request: AINetworkCallsRequestModel) -> Void)) {
		AINetworkCalls.globalRequestCallback = globalRequestCallback
	}
	
	final class func setGlobalUploadRequestCallback(globalUploadRequestCallback: @escaping ((_ request: UploadRequest) -> Void)) {
		AINetworkCalls.globalUploadRequestCallback = globalUploadRequestCallback
	}
	
	final class func setGlobalSuccessCallback(globalSuccessCallback: @escaping ((_ response: AFDataResponse<Any>, _ fetchResult: JSON) -> Void)) {
		AINetworkCalls.globalSuccessCallback = globalSuccessCallback
	}
	
	final class func setGlocalErrorCallBack(glocalErrorCallBack: @escaping ((_ response: AFDataResponse<Any>, _ fetchResult: JSON?, _ error: Error?, _ errorStatusCode: Int) -> Void)) {
		AINetworkCalls.glocalErrorCallBack = glocalErrorCallBack
	}
}
