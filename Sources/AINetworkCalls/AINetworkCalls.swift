import Foundation
import UIKit
import Alamofire
import SwiftyJSON


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
    
    private static var globalRequestCallback: ((_ requestModel: AINetworkCallsRequestModel)->Void)?
    private static var globalUploadRequestCallback: ((_ request: UploadRequest)->Void)?
    private static var globalSuccessCallback: ((_ response: AFDataResponse<Any>, _ fetchResult:JSON)->Void)?
    private static var glocalErrorCallBack: ((_ response: AFDataResponse<Any>, _ fetchResult:JSON?, _ error:Error?, _ errorStatusCode: Int)->Void)?
    
    // MARK: - API call methods
    public final class func get(fullPath:String, headers:HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            var path = fullPath
            path = path.replacingOccurrences(of: "//", with: "/") // double checking
            
            let headers: HTTPHeaders? = headers

            let parameters: [String : Any] = params ?? [String : Any]()
            
            self.globalRequestCallback?(AINetworkCallsRequestModel.init(withPath: path, method: "GET", headers: headers, parameters: parameters))
            
            AF.request(path, method: HTTPMethod.get, parameters: parameters, encoding: encoding ?? .queryString, headers: headers).validate(statusCode: 200..<300)
                .responseJSON { response in
                    AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
            }
        }
    }
    
    public final class func post(fullPath:String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            var path = fullPath
            path = path.replacingOccurrences(of: "//", with: "/") // double checking
            
            let headers: HTTPHeaders? = headers
            
            let parameters: [String : Any] = params ?? [String : Any]()
            
            self.globalRequestCallback?(AINetworkCallsRequestModel.init(withPath: path, method: "POST", headers: headers, body: parameters))
            
            AF.request(path, method: HTTPMethod.post, parameters: parameters, encoding: encoding ?? .default, headers: headers).validate(statusCode: 200..<300)
                .responseJSON { response in
                    AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
            }
        }
    }
    
    public final class func put(fullPath:String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            var path = fullPath
            path = path.replacingOccurrences(of: "//", with: "/") // double checking
            
            let headers: HTTPHeaders? = headers
            
            let parameters: [String : Any] = params ?? [String : Any]()
            
            self.globalRequestCallback?(AINetworkCallsRequestModel.init(withPath: path, method: "PUT", headers: headers, body: parameters))
            
            AF.request(path, method: HTTPMethod.put, parameters: parameters, encoding: encoding ?? .default, headers: headers).validate(statusCode: 200..<300)
                .responseJSON { response in
                    AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
            }
        }
    }
    
    public final class func multipart(fullPath:String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, multipartCallback: ((_ multipart:MultipartFormData) -> ())? = nil, progressCallback: ((_ fractionCompleted:Double) -> ())? = nil, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            var path = fullPath
            path = path.replacingOccurrences(of: "//", with: "/") // double checking
            
            let headers: HTTPHeaders? = headers

            let parameters: [String : Any] = params ?? [String : Any]()
            
            self.globalRequestCallback?(AINetworkCallsRequestModel.init(withPath: path, method: "MULTIPART", headers: headers, body: parameters))
            
            AF.upload(multipartFormData: { multiPart in
                multipartCallback?(multiPart)
                parameters.forEach {
                    if $0.value is UIImage {
                        multiPart.append(($0.value as! UIImage).jpegData(compressionQuality: 0.4)!, withName: $0.key, fileName: "image.png", mimeType: "image/jpg")
                    } else if $0.value is [[String: Any]] {
                        let json: JSON = JSON.init($0.value)
                        multiPart.append(json.rawString()!.data(using: .utf8)!, withName: $0.key)
                    } else if $0.value is [String: Any] {
                        let json: JSON = JSON.init($0.value)
                        multiPart.append(json.rawString()!.data(using: .utf8)!, withName: $0.key)
                    } else if $0.value is Data {
                        multiPart.append($0.value as! Data, withName: $0.key)
                    }
                }
            }, to: path, method: .post, headers: headers) .uploadProgress(queue: .main, closure: { progress in
                progressCallback?(progress.fractionCompleted)
            }).responseJSON(completionHandler: { response in
                AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
            })
        }
    }
    
    // MARK: - Callback methods
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

private extension AINetworkCalls {
    /**
     Handle Alamofire response
     
     - Author:
     Alexy
    */
    private final class func handleResponse(response: AFDataResponse<Any>, displayWarnings: Bool, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) {
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
    
    final class func handleError(_ error: Error?, errorCode:Int? = nil, fetchResult: [String: Any]? = nil) {
        switch errorCode {
        case URLError.Code.timedOut.rawValue:
            AINetworkCallsUtils.displayNativeMessage("Request Timeout")
        case URLError.Code.cannotParseResponse.rawValue:
            AINetworkCallsUtils.displayNativeMessage("Could not parse response")
        case URLError.Code.badServerResponse.rawValue:
            AINetworkCallsUtils.displayNativeMessage("Server is temporarily unavailable")
        default:
            AINetworkCallsUtils.displayNativeMessage("Error")
        }
    }
}
