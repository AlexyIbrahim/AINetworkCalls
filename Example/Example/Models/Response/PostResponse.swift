import Foundation

struct PostResponse: Decodable {
	let files: [String: String]
	let json: JsonData
	let args: [String: String]
	let url: String
	let form: [String: String]
	let headers: HeadersModel
	let data: JsonData
}

struct JsonData: Decodable {
	let hand: String
}

struct HeadersModel: Decodable {
	let accept: String
	let xForwardedPort: String
	let xForwardedProto: String
	let userAgent: String
	let acceptEncoding: String
	let contentType: String
	let host: String
	let contentLength: String
	let acceptLanguage: String
	let xAmznTraceId: String
	let xRequestStart: String
	let connection: String
	
	enum CodingKeys: String, CodingKey {
		case accept
		case xForwardedPort = "x-forwarded-port"
		case xForwardedProto = "x-forwarded-proto"
		case userAgent = "user-agent"
		case acceptEncoding = "accept-encoding"
		case contentType = "content-type"
		case host
		case contentLength = "content-length"
		case acceptLanguage = "accept-language"
		case xAmznTraceId = "x-amzn-trace-id"
		case xRequestStart = "x-request-start"
		case connection
	}
}
