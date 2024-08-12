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
	final class func request<T: Decodable>(httpMethod: AIHTTPMethod, baseUrl: BaseUrl, endpoint: String, headers: HTTPHeaders?, urlEncoding: URLEncoding? = nil, jsonEncoding: JSONEncoding? = nil, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, multipartFormData: MultipartFormData? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		switch httpMethod {
		case .get:
			return AINetworkCalls.get(baseUrl: baseUrl, endpoint: endpoint, headers: headers, encoding: urlEncoding, parameters: queryParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .post:
			return AINetworkCalls.post(baseUrl: baseUrl, endpoint: endpoint, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .put:
			return AINetworkCalls.put(baseUrl: baseUrl, endpoint: endpoint, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .multipart:
			guard let multipartFormData = multipartFormData else { return nil }
			return AINetworkCalls.multipart(baseUrl: baseUrl, endpoint: endpoint, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, multipartFormData: multipartFormData, progressCallback: { _ in }, successCallback: successCallback, errorCallback: errorCallback)
		case .delete:
			return AINetworkCalls.delete(baseUrl: baseUrl, endpoint: endpoint, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		default:
			return nil
		}
	}
	
	final class func request<T: Decodable>(httpMethod: AIHTTPMethod, fullPath: String, headers: HTTPHeaders?, urlEncoding: URLEncoding? = nil, jsonEncoding: JSONEncoding? = nil, queryParameters: [String: Any]? = nil, bodyParameters: [String: Any]? = nil, multipartFormData: MultipartFormData? = nil, displayWarnings: Bool = false, handleProgress: Bool? = nil, successCallback: GenericSuccessClosure<T>? = nil, errorCallback: GenericErrorClosure? = nil) -> DataRequest? {
		switch httpMethod {
		case .get:
			return AINetworkCalls.get(fullPath: fullPath, headers: headers, encoding: urlEncoding, parameters: queryParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .post:
			return AINetworkCalls.post(fullPath: fullPath, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .put:
			return AINetworkCalls.put(fullPath: fullPath, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		case .multipart:
			guard let multipartFormData = multipartFormData else { return nil }
			return AINetworkCalls.multipart(fullPath: fullPath, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, multipartFormData: multipartFormData, progressCallback: { _ in }, successCallback: successCallback, errorCallback: errorCallback)
		case .delete:
			return AINetworkCalls.delete(fullPath: fullPath, headers: headers, encoding: jsonEncoding, parameters: bodyParameters, displayWarnings: displayWarnings, handleProgress: handleProgress, successCallback: successCallback, errorCallback: errorCallback)
		default:
			return nil
		}
	}
}
