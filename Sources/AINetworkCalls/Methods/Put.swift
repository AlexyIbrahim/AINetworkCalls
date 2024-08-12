import Alamofire
import Foundation
import SwiftyJSON
import UIKit

public extension AINetworkCalls {
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
}
