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
    public final class func rxGet(endpointKey: String, function: String, headers:HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<JSON> {
        let path = AINetworkCalls.generatePathFromFunction(endpointKey: endpointKey, function: function)
        return AINetworkCalls.rxGet(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings)
    }
    public final class func rxGet(fullPath: String, headers:HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<JSON> {
        return Single<JSON>.create { single in
            let request = AINetworkCalls.get(fullPath: fullPath, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, successCallback: { (json) in
                single(.success(json))
            }) { (json, error) in
                single(.error(error!))
            }
            
            return Disposables.create {
                request?.cancel()
            }
        }
    }
    
    // MARK: POST
    public final class func rxPost(endpointKey: String, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<JSON> {
        let path = AINetworkCalls.generatePathFromFunction(endpointKey: endpointKey, function: function)
        return AINetworkCalls.rxPost(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings)
    }
    
    public final class func rxPost(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<JSON> {
        return Single<JSON>.create { single in
            let request = AINetworkCalls.post(fullPath: fullPath, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, successCallback: { (json) in
                single(.success(json))
            }) { (json, error) in
                single(.error(error!))
            }

            return Disposables.create {
                request?.cancel()
            }
        }
    }
    
    // MARK: PUT
    public final class func rxPut(endpointKey: String, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<JSON> {
        let path = AINetworkCalls.generatePathFromFunction(endpointKey: endpointKey, function: function)
        return AINetworkCalls.rxPut(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings)
    }
    public final class func rxPut(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false) -> Single<JSON> {
        return Single<JSON>.create { single in
            let request = AINetworkCalls.put(fullPath: fullPath, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, successCallback: { (json) in
                single(.success(json))
            }) { (json, error) in
                single(.error(error!))
            }
            
            return Disposables.create {
                request?.cancel()
            }
        }
    }
    
    // MARK: MULTIPART
    public final class func rxMultipart(endpointKey: String, function: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, multipartCallback: ((_ multipart:MultipartFormData) -> ())? = nil, progressCallback: ((_ fractionCompleted:Double) -> ())? = nil, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> Single<JSON> {
        let path = AINetworkCalls.generatePathFromFunction(endpointKey: endpointKey, function: function)
        return AINetworkCalls.rxMultipart(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, multipartCallback: multipartCallback, progressCallback: progressCallback, successCallback: successCallback, errorCallback: errorCallback)
    }
    public final class func rxMultipart(fullPath: String, headers:HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, multipartCallback: ((_ multipart:MultipartFormData) -> ())? = nil, progressCallback: ((_ fractionCompleted:Double) -> ())? = nil, successCallback: ((_ fetchResult:JSON) -> ())? = nil, errorCallback: ((_ fetchResult:JSON?, _ error:Error?) -> ())? = nil) -> Single<JSON> {
        return Single<JSON>.create { single in
            let request = AINetworkCalls.multipart(fullPath: fullPath, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, multipartCallback: multipartCallback, progressCallback: progressCallback, successCallback: { (json) in
                single(.success(json))
            }) { (json, error) in
                single(.error(error!))
            }
            
            return Disposables.create {
                request?.cancel()
            }
        }
    }
}
