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
	final class func handleResponse<T>(response: AFDataResponse<some Sendable>, displayWarnings _: Bool, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) where T: Decodable {
		switch response.result {
		case .success:
			if handleProgress ?? Config.shared.handleProgress {
				ProgressHUD.dismiss()
			}
			
			let json = JSON(response.value!)
			if Config.shared.isDebug {
				let url = response.request?.url?.absoluteString ?? "n/a"
				let method = response.request?.method?.rawValue ?? "n/a"
				let headers = response.request?.headers.dictionary ?? [:]
				let statusCode = response.response?.statusCode ?? 0
				var body: String? = nil
				if let jsonData = response.request?.httpBody {
					if let jsonString = String(data: jsonData, encoding: .utf8) {
						body = jsonString
					}
				}
				print("------- \(T.self) ------- [Success]")
				print("--- Request")
				print("[\(method)] \(url)")
				print("--- Headers")
				print("\(headers.isEmpty ? "n/a" : headers.description)")
				print("--- Body")
				print("\(body ?? "n/a")")
				print("--- Response [\(statusCode)]")
				var response = "\(json)"
				if Config.shared.trimLongResponse {
					response = AINetworkCallsUtils.truncate(str: response, length: Config.shared.longResponseCharLimit)
				}
				print("\(response)")
			}
			// 🌿 success callback
			if T.self == JSON.self {
				successCallback?(json as! T)
			} else if T.self == [String: Any].self {
				successCallback?(json.dictionaryObject as! T)
			} else {
				successCallback?(AINetworkCallsUtils.decode(model: T.self, from: json))
			}
			
			// 🌿 global callback
			if let castedResponse = response as? AFDataResponse<Any> {
				AINetworkCalls.globalSuccessCallback?(castedResponse, json)
			}
		case .failure:
			if handleProgress ?? Config.shared.handleProgress {
				AINetworkCalls.handleError(response.error, errorCode: response.response?.statusCode ?? 0)
			}
			
			// 🌿 json parsing
			var json: JSON? = nil
			do {
				if let data = response.data {
					json = try JSON(data: data)
				}
			} catch {}
			
			if Config.shared.isDebug {
				let url = response.request?.url?.absoluteString ?? "n/a"
				let method = response.request?.method?.rawValue ?? "n/a"
				let headers = response.request?.headers.dictionary ?? [:]
				var body: String? = nil
				if let jsonData = response.request?.httpBody {
					if let jsonString = String(data: jsonData, encoding: .utf8) {
						body = jsonString
					}
				}
				print("------- \(T.self) ------- [Failure]")
				print("--- Request")
				print("[\(method)] \(url)")
				print("--- Headers")
				print("\(headers.isEmpty ? "n/a" : headers.description)")
				print("--- Body")
				print("\(body ?? "n/a")")
				if let json = json {
					let statusCode = response.response?.statusCode ?? 0
					print("--- Response [\(statusCode)]")
					var response = "\(json)"
					if Config.shared.trimLongResponse {
						response = AINetworkCallsUtils.truncate(str: response, length: Config.shared.longResponseCharLimit)
					}
					print("\(response)")
				}
			}
			
			// 🌿 callback
			errorCallback?(json ?? nil, response.error)
			if let castedResponse = response as? AFDataResponse<Any> {
				AINetworkCalls.glocalErrorCallBack?(castedResponse, json ?? nil, response.error, response.response?.statusCode ?? 0)
			}
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
