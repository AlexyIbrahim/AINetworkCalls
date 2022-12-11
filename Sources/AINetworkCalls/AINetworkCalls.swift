import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import RxCocoa
import RxSwift

public struct AINetworkCallsRequestModel {
    
    private var _path: String? = nil
    private var _method: AIHTTPMethod? = nil
    private var _headers: HTTPHeaders? = nil
    private var _parameters: [String : Any]? = nil
    private var _body: [String : Any]? = nil
    
    public var path: String? {
        return _path
    }
    public var method: AIHTTPMethod? {
        return _method
    }
    public var headers: HTTPHeaders? {
        return _headers
    }
    public var parameters: [String : Any]? {
        return _parameters
    }
    public var body: [String : Any]? {
        return _body
    }
    
    internal init(withPath path: String?, method: AIHTTPMethod? = nil, headers: HTTPHeaders? = nil, parameters: [String : Any]? = nil, body: [String : Any]? = nil) {
        self._path = path
        self._method = method
        self._headers = headers
        self._parameters = parameters
        self._body = body
    }
    
    public func toJson() -> [String: Any] {
        var data = [String: Any]()
        data.safelyAdd(self.path, forKey: "path")
        data.safelyAdd(self.method, forKey: "method")
        data.safelyAdd(self.headers, forKey: "headers")
        data.safelyAdd(self.parameters, forKey: "parameters")
        data.safelyAdd(self.body, forKey: "body")
        
        return data
    }
}

public class AINetworkCalls: NSObject {
    
    private static var localManager: Alamofire.Session?
    
    public static func initManager(interceptor: RequestInterceptor? = nil) {
        localManager = Session.init(interceptor: interceptor)
    }
    
    internal static var manager: Alamofire.Session = {
        if let localManager = localManager {
            return localManager
        } else {
            localManager = Session.init()
            return localManager!
        }
    }()
    
    public static var config: Config {
        get { Config.shared }
        set { Config.shared = newValue }
    }
    
    internal static var globalRequestCallback: ((_ requestModel: AINetworkCallsRequestModel)->Void)?
    private static var globalUploadRequestCallback: ((_ request: UploadRequest)->Void)?
    private static var globalSuccessCallback: ((_ response: AFDataResponse<Any>, _ fetchResult:JSON)->Void)?
    private static var glocalErrorCallBack: ((_ response: AFDataResponse<Any>, _ fetchResult:JSON?, _ error:Error?, _ errorStatusCode: Int)->Void)?
    
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
    
    
    
    internal final class func tidyFunction(_ function: String) -> String {
        var functionStr: String = (function.hasPrefix("/") ? function : "/\(function)")
        functionStr = function.replacingOccurrences(of: "//", with: "/")
        return functionStr
//        AINetworkCalls.manager.interceptor = RequestInterceptor()
    }
    
    internal final class func generatePathFromFunction(endpoint: Endpoint, function: String) -> String {
        return AINetworkCalls.generatePathFromFunction(endpoint: endpoint.rawValue, function: function)
    }
    
    internal final class func generatePathFromFunction(endpoint: String, function: String) -> String {
        var path = endpoint + tidyFunction(function)
        path = path.replacingOccurrences(of: "//", with: "/")
        return path
    }
}

// MARK: - Handling
extension AINetworkCalls {
    internal final class func handleRequest(_ requestModel: AINetworkCallsRequestModel) {
        self.globalRequestCallback?(requestModel)
    }
    
    /**
     Handle Alamofire response
     
     - Author:
     Alexy
    */
    internal final class func handleResponse<T>(response: AFDataResponse<Any>, displayWarnings: Bool, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) where T : Decodable {
        
        switch response.result {
        case .success:
            let json = JSON.init(response.value!)
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
                print("--- Body")
                print("\(body ?? "n/a")")
                print("--- Headers")
                print("\(headers.isEmpty ? "n/a" : headers.description)")
                print("--- Response [\(statusCode)]")
                var response: String = ""
                if Config.shared.trimLongResponse {
                    response = AINetworkCallsUtils.truncate(str: json.stringValue, length: Config.shared.longResponseCharLimit)
                }
                print("\(response)")
            }
            // 🌿 success callback
            if T.self == JSON.self {
                successCallback?(json as! T)
            } else if T.self == Dictionary<String, Any>.self {
                successCallback?(json.dictionaryObject as! T)
            } else {
                successCallback?(AINetworkCallsUtils.decode(model: T.self, from: json))
            }
            
            // 🌿 global callback
            AINetworkCalls.globalSuccessCallback?(response, json)
        case .failure(_):
            // 🌿 json parsing
            var json: JSON? = nil
            do {
                if let data = response.data {
                    json = try JSON.init(data: data)
                }
            } catch {
            }
            
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
                print("------- \(T.self) ------- [Success]")
                print("--- Request")
                print("[\(method)] \(url)")
                print("--- Body")
                print("\(body ?? "n/a")")
                print("--- Headers")
                print("\(headers.isEmpty ? "n/a" : headers.description)")
                if let json = json {
                    let statusCode = response.response?.statusCode ?? 0
                    print("--- Response [\(statusCode)]")
                    var response: String = ""
                    if Config.shared.trimLongResponse {
                        response = AINetworkCallsUtils.truncate(str: json.stringValue, length: Config.shared.longResponseCharLimit)
                    }
                    print("\(response)")
                }
            }
            
            // 🌿 callback
            errorCallback?(json ?? nil, response.error)
            AINetworkCalls.glocalErrorCallBack?(response, json ?? nil, response.error, response.response?.statusCode ?? 0)
            // 🌿 warning errors
            if displayWarnings {AINetworkCalls.handleError(response.error, errorCode: response.response?.statusCode ?? 0)}
        }
    }
    
    final private class func handleError(_ error: Error?, errorCode:Int? = nil, fetchResult: [String: Any]? = nil) {
        switch errorCode {
        case URLError.Code.timedOut.rawValue:
            AINetworkCallsUtils.displayMessage("Request Timeout")
        case URLError.Code.cannotParseResponse.rawValue:
            AINetworkCallsUtils.displayMessage("Could not parse response")
        case URLError.Code.badServerResponse.rawValue:
            AINetworkCallsUtils.displayMessage("Server is temporarily unavailable")
        default:
            AINetworkCallsUtils.displayMessage("Error")
        }
    }
}


// MARK: - Misc
extension AINetworkCalls {
    public final class func enableDebug() {
        Config.shared.isDebug = true
    }
    
    public final class func disableDebug() {
        Config.shared.isDebug = false
    }
    
    // MARK: Callback methods
    public final class func setGlobalRequestCallback(globalRequestCallback:@escaping ((_ request: AINetworkCallsRequestModel)->Void)) {
        AINetworkCalls.globalRequestCallback = globalRequestCallback
    }
    
    public final class func setGlobalUploadRequestCallback(globalUploadRequestCallback:@escaping ((_ request: UploadRequest)->Void)) {
        AINetworkCalls.globalUploadRequestCallback = globalUploadRequestCallback
    }
    public final class func setGlobalSuccessCallback(globalSuccessCallback:@escaping ((_ response: AFDataResponse<Any>, _ fetchResult:JSON)->Void)) {
        AINetworkCalls.globalSuccessCallback = globalSuccessCallback
    }
    
    public final class func setGlocalErrorCallBack(glocalErrorCallBack: @escaping ((_ response: AFDataResponse<Any>, _ fetchResult:JSON?, _ error:Error?, _ errorStatusCode: Int)->Void)) {
        AINetworkCalls.glocalErrorCallBack = glocalErrorCallBack
    }
}
