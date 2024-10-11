import AINetworkCalls
import Alamofire
import Foundation
import Promises
import SwiftyJSON
import UIKit

public extension BaseUrl {
	static let backend_path = BaseUrl(rawValue: "https://postman-echo.com/")
}

typealias APICalls = APIBlueprints.Contract
enum APIBlueprints {
	static let backgroundQueue: DispatchQueue = .global(qos: .background)
	
	enum Contract: AIServiceModule {
		case postMethod(paramters: PostRequest)
		case error
		
		var aiUrl: AIUrl {
			switch self {
			default: return .init(baseUrl: .backend_path)
			}
		}
		
		var handleProgress: Bool? {
			switch self {
			default: return true
			}
		}
		
		var method: AIHTTPMethod {
			switch self {
			case .error: return .get
			case .postMethod
				:
				return .post
			}
		}
		
		var bodyParameters: Parameters? {
			switch self {
			case let .postMethod(parameters): return parameters.dictionary!
			default: return nil
			}
		}
		
		var queryParameters: Parameters? {
			return nil
		}
		
		var headers: HTTPHeaders? {
			return nil
		}
		
		var endpoint: String? {
			switch self {
			case .postMethod:
				return "post"
			case .error:
				return "status/404"
			}
		}
		
		var multipartFormData: MultipartFormData? {
			return nil
		}
	}
}


