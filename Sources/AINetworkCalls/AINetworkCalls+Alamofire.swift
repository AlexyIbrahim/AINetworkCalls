//
//  File.swift
//  
//
//  Created by Alexy Ibrahim on 19/07/2021.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

// MARK: - Alamofire
extension AINetworkCalls {
    
    public final class func request(httpMethod: AIHTTPMethod, endpointKey: String, function: String, headers:HTTPHeaders?, urlEncoding: URLEncoding? = nil, jsonEncoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, body: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil)  -> DataRequest? {
        
        switch httpMethod {
        case .get:
            return AINetworkCalls.get(endpointKey: endpointKey, function: function, headers: headers, encoding: urlEncoding, parameters: params, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
        case .post:
            return AINetworkCalls.post(endpointKey: endpointKey, function: function, headers: headers, encoding: jsonEncoding, parameters: params, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
        case .put:
            return AINetworkCalls.put(endpointKey: endpointKey, function: function, headers: headers, encoding: jsonEncoding, parameters: params, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
        default:
            return nil
        }
    }
    
    // MARK: GET
    public final class func get(endpointKey: String, function: String, headers:HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> DataRequest? {
        let path = AINetworkCalls.generatePathFromFunction(endpointKey: endpointKey, function: function)
        return AINetworkCalls.get(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func get(fullPath: String, headers:HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> DataRequest? {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            let headers: HTTPHeaders? = headers

            let parameters: [String : Any] = params ?? [String : Any]()
            
            self.globalRequestCallback?(AINetworkCallsRequestModel.init(withPath: fullPath, method: "GET", headers: headers, parameters: parameters))
            
            let request = AF.request(fullPath, method: HTTPMethod.get, parameters: parameters, encoding: encoding ?? .queryString, headers: headers).validate(statusCode: 200..<300)
                .responseJSON { response in
                    AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
            }
            return request
        }
        return nil
    }
    
    // MARK: POST
    public final class func post(endpointKey: String, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> DataRequest? {
        let path = AINetworkCalls.generatePathFromFunction(endpointKey: endpointKey, function: function)
        return AINetworkCalls.post(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func post(fullPath:String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> DataRequest? {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            let headers: HTTPHeaders? = headers
            
            let parameters: [String : Any] = params ?? [String : Any]()
            
            self.globalRequestCallback?(AINetworkCallsRequestModel.init(withPath: fullPath, method: "POST", headers: headers, body: parameters))
            
            let request = AF.request(fullPath, method: HTTPMethod.post, parameters: parameters, encoding: encoding ?? .default, headers: headers).validate(statusCode: 200..<300)
                .responseJSON { response in
                    AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
            }
            return request
        }
        return nil
    }
    
    // MARK: PUT
    public final class func put(endpointKey: String, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> DataRequest? {
        let path = AINetworkCalls.generatePathFromFunction(endpointKey: endpointKey, function: function)
        return AINetworkCalls.put(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func put(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> DataRequest? {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            let headers: HTTPHeaders? = headers
            
            let parameters: [String : Any] = params ?? [String : Any]()
            
            self.globalRequestCallback?(AINetworkCallsRequestModel.init(withPath: fullPath, method: "PUT", headers: headers, body: parameters))
            
            let request = AF.request(fullPath, method: HTTPMethod.put, parameters: parameters, encoding: encoding ?? .default, headers: headers).validate(statusCode: 200..<300)
                .responseJSON { response in
                    AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
            }
            return request
        }
        return nil
    }
    
    // MARK: MULTIPART
    public final class func multipart(endpointKey: String, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, multipartCallback: ((_ multipart:MultipartFormData) -> ())? = nil, progressCallback: ((_ fractionCompleted:Double) -> ())? = nil, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> UploadRequest? {
        let path = AINetworkCalls.generatePathFromFunction(endpointKey: endpointKey, function: function)
        
        return AINetworkCalls.multipart(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, multipartCallback: multipartCallback, progressCallback: progressCallback, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func multipart(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, multipartCallback: ((_ multipart:MultipartFormData) -> ())? = nil, progressCallback: ((_ fractionCompleted:Double) -> ())? = nil, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> UploadRequest? {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            
            let headers: HTTPHeaders? = headers

            let parameters: [String : Any] = params ?? [String : Any]()
            
            self.globalRequestCallback?(AINetworkCallsRequestModel.init(withPath: fullPath, method: "MULTIPART", headers: headers, body: parameters))
            
            let request = AF.upload(multipartFormData: { multiPart in
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
            }, to: fullPath, method: .post, headers: headers) .uploadProgress(queue: .main, closure: { progress in
                progressCallback?(progress.fractionCompleted)
            }).responseJSON(completionHandler: { response in
                AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, successCallback: successCallback, errorCallback: errorCallback)
            })
            return request
        }
        return nil
    }
}
