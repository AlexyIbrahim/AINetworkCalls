//
//  AINetworkCalls+Callback.swift
//
//
//  Created by Alexy Ibrahim on 19/07/2021.
//

import Alamofire
import Foundation
import SwiftyJSON
import UIKit

// MARK: - Alamofire

public extension AINetworkCalls {
	final class func request<T: Decodable>(httpMethod: AIHTTPMethod, baseUrl: BaseUrl, endpoint: String, headers: HTTPHeaders?, urlEncoding: URLEncoding? = nil, jsonEncoding: JSONEncoding? = nil, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		switch httpMethod {
		case .get:
			return AINetworkCalls.get(baseUrl: baseUrl, endpoint: endpoint, headers: headers, encoding: urlEncoding, parameters: queryParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .post:
			return AINetworkCalls.post(baseUrl: baseUrl, endpoint: endpoint, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .put:
			return AINetworkCalls.put(baseUrl: baseUrl, endpoint: endpoint, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .multipart:
			return AINetworkCalls.multipart(baseUrl: baseUrl, endpoint: endpoint, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, multipartCallback: { _ in }, progressCallback: { _ in }, successCallback: successCallback, errorCallback: errorCallback)
		default:
			return nil
		}
	}
	
	final class func request<T: Decodable>(httpMethod: AIHTTPMethod, fullPath: String, headers: HTTPHeaders?, urlEncoding: URLEncoding? = nil, jsonEncoding: JSONEncoding? = nil, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		switch httpMethod {
		case .get:
			return AINetworkCalls.get(fullPath: fullPath, headers: headers, encoding: urlEncoding, parameters: queryParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .post:
			return AINetworkCalls.post(fullPath: fullPath, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .put:
			return AINetworkCalls.put(fullPath: fullPath, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .multipart:
			return AINetworkCalls.multipart(fullPath: fullPath, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, multipartCallback: { _ in }, progressCallback: { _ in }, successCallback: successCallback, errorCallback: errorCallback)
		default:
			return nil
		}
	}
	
	// MARK: GET
	
	final class func get<T: Decodable>(baseUrl: BaseUrl, endpoint: String, headers: HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		let path = AINetworkCalls.generateFullPath(baseUrl: baseUrl, endpoint: endpoint)
		return AINetworkCalls.get(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
	}
	
	final class func get<T: Decodable>(fullPath: String, headers: HTTPHeaders?, encoding: URLEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: ((_ fetchResult: T) -> Void)? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
			let headers: HTTPHeaders? = headers
			
			let parameters: [String: Any] = params ?? [String: Any]()
			
			AINetworkCalls.handleRequest(AINetworkCallsRequestModel(withPath: fullPath, method: .get, headers: headers, parameters: parameters), handleProgress: handleProgress)
			
			let request = manager.request(fullPath, method: HTTPMethod.get, parameters: parameters, encoding: encoding ?? .queryString, headers: headers).validate(statusCode: 200 ..< 300)
				.responseJSON { response in
					AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
				}
			return request
		}
		return nil
	}
	
	// MARK: POST
	
	final class func post<T: Decodable>(baseUrl: BaseUrl, endpoint: String, headers: HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		let path = AINetworkCalls.generateFullPath(baseUrl: baseUrl, endpoint: endpoint)
		return AINetworkCalls.post(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
	}
	
	final class func post<T: Decodable>(fullPath: String, headers: HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
			let headers: HTTPHeaders? = headers
			
			let parameters: [String: Any] = params ?? [String: Any]()
			
			AINetworkCalls.handleRequest(AINetworkCallsRequestModel(withPath: fullPath, method: .post, headers: headers, body: parameters), handleProgress: handleProgress)
			
			let request = manager.request(fullPath, method: HTTPMethod.post, parameters: parameters, encoding: encoding ?? .default, headers: headers).validate(statusCode: 200 ..< 300)
				.responseJSON { response in
					AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
				}
			return request
		}
		return nil
	}
	
	// MARK: PUT
	
	final class func put<T: Decodable>(baseUrl: BaseUrl, endpoint: String, headers: HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		let path = AINetworkCalls.generateFullPath(baseUrl: baseUrl, endpoint: endpoint)
		return AINetworkCalls.put(fullPath: path, headers: headers, encoding: encoding, parameters: params, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
	}
	
	final class func put<T: Decodable>(fullPath: String, headers: HTTPHeaders?, encoding: JSONEncoding? = nil, parameters params: [String: Any]? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		if AINetworkCallsUtils.canProceedWithRequest(displayWarning: displayWarnings) {
			let headers: HTTPHeaders? = headers
			
			let parameters: [String: Any] = params ?? [String: Any]()
			
			AINetworkCalls.handleRequest(AINetworkCallsRequestModel(withPath: fullPath, method: .put, headers: headers, body: parameters), handleProgress: handleProgress)
			
			let request = manager.request(fullPath, method: HTTPMethod.put, parameters: parameters, encoding: encoding ?? .default, headers: headers).validate(statusCode: 200 ..< 300)
				.responseJSON { response in
					AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
				}
			return request
		}
		return nil
	}
	
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
			}).responseJSON(completionHandler: { response in
				AINetworkCalls.handleResponse(response: response, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
			})
			return request
		}
		return nil
	}
}
