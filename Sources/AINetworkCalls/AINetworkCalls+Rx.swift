//
//  File.swift
//  
//
//  Created by Alexy Ibrahim on 19/07/2021.
//

import Foundation
import Alamofire
import SwiftyJSON
import RxCocoa
import RxSwift

// MARK: - rx
extension AINetworkCalls {
    
    // MARK: GET
    public final class func rxGet<T: Decodable>(endpoint: AIEndpoint, function: String, headers:HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<T> {
        let path = AINetworkCalls.generatePathFromFunction(endpoint: endpoint, function: function)
        return AINetworkCalls.rxGet(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings)
    }
    public final class func rxGet<T: Decodable>(fullPath: String, headers:HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<T> {
        return Single<T>.create { single in
            let request = AINetworkCalls.get(fullPath: fullPath, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, successCallback: { (response) in
                single(.success(response))
            }) { (json, error) in
                single(.error(error!))
            }
            
            return Disposables.create {
                request?.cancel()
            }
        }
    }
    
    // MARK: POST
    public final class func rxPost<T: Decodable>(endpoint: AIEndpoint, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<T> {
        let path = AINetworkCalls.generatePathFromFunction(endpoint: endpoint, function: function)
        return AINetworkCalls.rxPost(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings)
    }
    
    public final class func rxPost<T: Decodable>(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<T> {
        return Single<T>.create { single in
            let request = AINetworkCalls.post(fullPath: fullPath, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, successCallback: { (response) in
                single(.success(response))
            }) { (json, error) in
                single(.error(error!))
            }

            return Disposables.create {
                request?.cancel()
            }
        }
    }
    
    // MARK: PUT
    public final class func rxPut<T: Decodable>(endpoint: AIEndpoint, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<T> {
        let path = AINetworkCalls.generatePathFromFunction(endpoint: endpoint, function: function)
        return AINetworkCalls.rxPut(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings)
    }
    public final class func rxPut<T: Decodable>(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<T> {
        return Single<T>.create { single in
            let request = AINetworkCalls.put(fullPath: fullPath, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, successCallback: { (response) in
                single(.success(response))
            }) { (json, error) in
                single(.error(error!))
            }
            
            return Disposables.create {
                request?.cancel()
            }
        }
    }
    
    // MARK: MULTIPART
    public final class func rxMultipart<T: Decodable>(endpoint: AIEndpoint, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, multipartCallback: ((_ multipart:MultipartFormData) -> ())? = nil, progressCallback: ((_ fractionCompleted:Double) -> ())? = nil, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> Single<T> {
        let path = AINetworkCalls.generatePathFromFunction(endpoint: endpoint, function: function)
        return AINetworkCalls.rxMultipart(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, multipartCallback: multipartCallback, progressCallback: progressCallback, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func rxMultipart<T: Decodable>(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, multipartCallback: ((_ multipart:MultipartFormData) -> ())? = nil, progressCallback: ((_ fractionCompleted:Double) -> ())? = nil, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> Single<T> {
        return Single<T>.create { single in
            let request = AINetworkCalls.multipart(fullPath: fullPath, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, multipartCallback: multipartCallback, progressCallback: progressCallback, successCallback: { (response) in
                single(.success(response))
            }) { (json, error) in
                single(.error(error!))
            }
            
            return Disposables.create {
                request?.cancel()
            }
        }
    }
}
