import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import RxCocoa
import RxSwift

public struct AINetworkCallsRequestModel {
    private var _path: String? = nil
    private var _method: String? = nil
    private var _headers: HTTPHeaders? = nil
    private var _parameters: [String : Any]? = nil
    private var _body: [String : Any]? = nil
    
    public var path: String? {
        return _path
    }
    public var method: String? {
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
    
    internal init(withPath path: String?, method: String? = nil, headers: HTTPHeaders? = nil, parameters: [String : Any]? = nil, body: [String : Any]? = nil) {
        self._path = path
        self._method = method
        self._headers = headers
        self._parameters = parameters
        self._body = body
    }
    
    public func toJson() -> [String:Any] {
        var data = [String:Any]()
        data.safelyAdd(self.path, forKey: "path")
        data.safelyAdd(self.method, forKey: "method")
        data.safelyAdd(self.headers, forKey: "headers")
        data.safelyAdd(self.parameters, forKey: "parameters")
        data.safelyAdd(self.body, forKey: "body")
        
        return data
    }
}

public class AINetworkCalls: NSObject {
    
    internal static var globalRequestCallback: ((_ requestModel: AINetworkCallsRequestModel)->Void)?
    private static var globalUploadRequestCallback: ((_ request: UploadRequest)->Void)?
    private static var globalSuccessCallback: ((_ response: AFDataResponse<Any>, _ fetchResult:JSON)->Void)?
    private static var glocalErrorCallBack: ((_ response: AFDataResponse<Any>, _ fetchResult:JSON?, _ error:Error?, _ errorStatusCode: Int)->Void)?
    
    public final class func initWithEndpoints(_ endpoints: [AIEndpoint]) {
        LifecycleVars.endpoints = endpoints
    }
    
    public final class func addEndpoints(_ endpoints: [AIEndpoint]) {
        LifecycleVars.endpoints.append(contentsOf: endpoints)
    }
    
    public final class func endpoints() -> [AIEndpoint] {
        LifecycleVars.endpoints
    }
    
    
    
    internal final class func tidyFunction(_ function: String) -> String {
        var functionStr: String = (function.hasPrefix("/") ? function : "/\(function)")
        functionStr = function.replacingOccurrences(of: "//", with: "/")
        return functionStr
    }
    
    internal final class func generatePathFromFunction(endpointKey: String, function: String) -> String {
        guard let endpoint = LifecycleVars.endpointForKey(endpointKey) else {
            return ""
        }
        var path = endpoint + tidyFunction(function)
        path = path.replacingOccurrences(of: "//", with: "/")
        return path
    }
}

// MARK: - Handling
extension AINetworkCalls {
    /**
     Handle Alamofire response
     
     - Author:
     Alexy
    */
    internal final class func handleResponse(response: AFDataResponse<Any>, displayWarnings: Bool, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) {
        switch response.result {
        case .success:
            let json = JSON.init(response.value!)
            
            // 🌿 callback
            successCallback?(json)
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
