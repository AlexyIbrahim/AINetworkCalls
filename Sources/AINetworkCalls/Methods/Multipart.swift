import Alamofire
import Foundation
import SwiftyJSON
import UIKit

public extension AINetworkCalls {
	// MARK: MULTIPART
	
	final class func multipart<T: Decodable>(baseUrl: BaseUrl, endpoint: String, headers: HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, multipartCallback: ((_ multipart: MultipartFormData) -> Void)? = nil, progressCallback: ((_ fractionCompleted: Double) -> Void)? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> UploadRequest? {
		let path = AINetworkCalls.generateFullPath(baseUrl: baseUrl, endpoint: endpoint)
		
		return AINetworkCalls.multipart(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, handleProgress: handleProgress, multipartCallback: multipartCallback, progressCallback: progressCallback, successCallback: successCallback, errorCallback: errorCallback)
	}
	
	final class func multipart<T: Decodable>(fullPath: String, headers: HTTPHeaders?, encoding _: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, multipartCallback: ((_ multipart: MultipartFormData) -> Void)? = nil, progressCallback: ((_ fractionCompleted: Double) -> Void)? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> UploadRequest? {
		if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
			let headers: HTTPHeaders? = headers
			
			let parameters: [String: Any] = params ?? [String: Any]()
			
			AINetworkCalls.handleRequest(AINetworkCallsRequestModel(withPath: fullPath, method: .multipart, headers: headers, body: parameters), handleProgress: handleProgress)
			
			
			let request = manager.upload(multipartFormData: { multiPart in
				multipartCallback?(multiPart)
				for parameter in parameters {
					if parameter.value is UIImage {
						multiPart.append((parameter.value as! UIImage).jpegData(compressionQuality: 0.4)!, withName: parameter.key, fileName: "image.png", mimeType: "image/jpg")
					} else if parameter.value is [[String: Any]] {
						let json = JSON(parameter.value)
						multiPart.append(json.rawString()!.data(using: .utf8)!, withName: parameter.key)
					} else if parameter.value is [String: Any] {
						let json = JSON(parameter.value)
						multiPart.append(json.rawString()!.data(using: .utf8)!, withName: parameter.key)
					} else if parameter.value is Data {
						multiPart.append(parameter.value as! Data, withName: parameter.key)
					}
				}
			}, to: fullPath, method: .post, headers: headers).uploadProgress(queue: .main, closure: { progress in
				progressCallback?(progress.fractionCompleted)
			}).responseDecodable(of: T.self, completionHandler: { response in
				AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
			})
			return request
		}
		return nil
	}
	
	final class func multipart<T: Decodable>(baseUrl: BaseUrl, endpoint: String, headers: HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, multipartFormData: MultipartFormData, progressCallback: ((_ fractionCompleted: Double) -> Void)? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> UploadRequest? {
		let path = AINetworkCalls.generateFullPath(baseUrl: baseUrl, endpoint: endpoint)
		
		return AINetworkCalls.multipart(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, handleProgress: handleProgress, multipartFormData: multipartFormData, progressCallback: progressCallback, successCallback: successCallback, errorCallback: errorCallback)
	}
	
	final class func multipart<T: Decodable>(fullPath: String, headers: HTTPHeaders?, encoding _: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, multipartFormData: MultipartFormData, progressCallback: ((_ fractionCompleted: Double) -> Void)? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> UploadRequest? {
		if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
			let headers: HTTPHeaders? = headers
			
			let parameters: [String: Any] = params ?? [String: Any]()
			
			AINetworkCalls.handleRequest(AINetworkCallsRequestModel(withPath: fullPath, method: .multipart, headers: headers, body: parameters), handleProgress: handleProgress)
			
			
			for parameter in parameters {
				if parameter.value is UIImage {
					multipartFormData.append((parameter.value as! UIImage).jpegData(compressionQuality: 0.4)!, withName: parameter.key, fileName: "image.png", mimeType: "image/jpg")
				} else if parameter.value is [[String: Any]] {
					let json = JSON(parameter.value)
					multipartFormData.append(json.rawString()!.data(using: .utf8)!, withName: parameter.key)
				} else if parameter.value is [String: Any] {
					let json = JSON(parameter.value)
					multipartFormData.append(json.rawString()!.data(using: .utf8)!, withName: parameter.key)
				} else if parameter.value is Data {
					multipartFormData.append(parameter.value as! Data, withName: parameter.key)
				}
			}
			let request = manager.upload(multipartFormData: multipartFormData, to: fullPath, method: .post, headers: headers).uploadProgress(queue: .main, closure: { progress in
				progressCallback?(progress.fractionCompleted)
			}).responseDecodable(of: T.self, completionHandler: { response in
				AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
			})
			return request
		}
		return nil
	}
}
