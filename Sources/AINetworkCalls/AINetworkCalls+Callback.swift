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
    
    public final class func request<T: Decodable>(httpMethod: AIHTTPMethod, endpoint: Endpoint, function: String, headers:HTTPHeaders?, urlEncoding: URLEncoding? = nil, jsonEncoding: JSONEncoding? = nil, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil)  -> DataRequest? {
        
        switch httpMethod {
        case .get:
            return AINetworkCalls.get(endpoint: endpoint, function: function, headers: headers, encoding: urlEncoding, parameters: queryParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
        case .post:
            return AINetworkCalls.post(endpoint: endpoint, function: function, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
        case .put:
            return AINetworkCalls.put(endpoint: endpoint, function: function, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
        default:
            return nil
        }
    }
    
    // MARK: GET
    public final class func get<T: Decodable>(endpoint: Endpoint, function: String, headers:HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
        let path = AINetworkCalls.generatePathFromFunction(endpoint: endpoint, function: function)
        return AINetworkCalls.get(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func get<T: Decodable>(fullPath: String, headers:HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: ((_ fetchResult:T) -> ())? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            let headers: HTTPHeaders? = headers

            let parameters: [String : Any] = params ?? [String : Any]()
            
            AINetworkCalls.handleRequest(AINetworkCallsRequestModel.init(withPath: fullPath, method: .get, headers: headers, parameters: parameters), handleProgress: handleProgress)
            
            let request = manager.request(fullPath, method: HTTPMethod.get, parameters: parameters, encoding: encoding ?? .queryString, headers: headers).validate(statusCode: 200..<300)
                .responseJSON { response in
                    AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
            }
            return request
        }
        return nil
    }
    
    // MARK: POST
    public final class func post<T: Decodable>(endpoint: Endpoint, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
        let path = AINetworkCalls.generatePathFromFunction(endpoint: endpoint, function: function)
        return AINetworkCalls.post(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func post<T: Decodable>(fullPath:String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            let headers: HTTPHeaders? = headers
            
            let parameters: [String : Any] = params ?? [String : Any]()
            
            AINetworkCalls.handleRequest(AINetworkCallsRequestModel.init(withPath: fullPath, method: .post, headers: headers, body: parameters), handleProgress: handleProgress)
            
            let request = manager.request(fullPath, method: HTTPMethod.post, parameters: parameters, encoding: encoding ?? .default, headers: headers).validate(statusCode: 200..<300)
                .responseJSON { response in
                    AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
            }
            return request
        }
        return nil
    }
    
    // MARK: PUT
    public final class func put<T: Decodable>(endpoint: Endpoint, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
        let path = AINetworkCalls.generatePathFromFunction(endpoint: endpoint, function: function)
        return AINetworkCalls.put(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func put<T: Decodable>(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            let headers: HTTPHeaders? = headers
            
            let parameters: [String : Any] = params ?? [String : Any]()
            
            AINetworkCalls.handleRequest(AINetworkCallsRequestModel.init(withPath: fullPath, method: .put, headers: headers, body: parameters), handleProgress: handleProgress)
            
            let request = manager.request(fullPath, method: HTTPMethod.put, parameters: parameters, encoding: encoding ?? .default, headers: headers).validate(statusCode: 200..<300)
                .responseJSON { response in
                    AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
            }
            return request
        }
        return nil
    }
    
    // MARK: MULTIPART
    public final class func multipart<T: Decodable>(endpoint: Endpoint, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, multipartCallback: ((_ multipart:MultipartFormData) -> ())? = nil, progressCallback: ((_ fractionCompleted:Double) -> ())? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> UploadRequest? {
        let path = AINetworkCalls.generatePathFromFunction(endpoint: endpoint, function: function)
        
        return AINetworkCalls.multipart(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, handleProgress: handleProgress, multipartCallback: multipartCallback, progressCallback: progressCallback, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func multipart<T: Decodable>(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, multipartCallback: ((_ multipart:MultipartFormData) -> ())? = nil, progressCallback: ((_ fractionCompleted:Double) -> ())? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> UploadRequest? {
        if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
            
            let headers: HTTPHeaders? = headers

            let parameters: [String : Any] = params ?? [String : Any]()
            
            AINetworkCalls.handleRequest(AINetworkCallsRequestModel.init(withPath: fullPath, method: .multipart, headers: headers, body: parameters), handleProgress: handleProgress)
            
            let request = manager.upload(multipartFormData: { multiPart in
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
                AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
            })
            return request
        }
        return nil
    }
}
