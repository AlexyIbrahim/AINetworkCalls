import AINetworkCalls
import Alamofire
import Foundation
import Promises
import SwiftyJSON
import UIKit

typealias APICalls = APIBlueprints.Contract
enum APIBlueprints {
	static let backgroundQueue: DispatchQueue = .global(qos: .background)
	
	enum Contract: AIServiceModule {
		case login(parameters: LoginRequest)
		case getUser
		case refreshToken
		case uploadImage(parameters: UploadImageRequest)
		case updateUser(parameters: UpdateUserRequest)
		case requestCode(parameters: RequestCodeRequest)
		case verifyCode(parameters: VerifyCodeRequest)
		case registerUser(parameters: RegisterUserRequest)
		case modifyEmail(parameters: ModifyEmailRequest)
		case modifyMobile(parameters: ModifyMobileRequest)
		case getAddresses
		case addAddress(parameters: AddAddressRequest)
		case editAddress(parameters: EditAddressRequest)
		case deleteAddress(parameters: DeleteAddressRequest)
		case modifyPassword(parameters: ModifyPasswordRequest)
		case about
		case terms
		case privacy
		case submitFeedback(parameters: FeedbackRequest)
		case getGoals
		case getFilteredPlans(parameters: FilterPlansRequest)
		case getFitnessCategories
		case getProfessionals(parameters: GetProfessionalsRequest)
		case getProfessionalAvailability(parameters: GetProfessionalAvailability)
		case getPlan
		case bookPlan(parameters: BookPlanRequest)
		case getBookingDates
		case makeConsultationBooking(parameters: MakeConsultationBookingRequest)
		case getBookings
		
		var aiUrl: AIUrl {
			switch self {
			default: return .init(baseUrl: .backend_path)
			}
		}
		
		var handleProgress: Bool? {
			switch self {
			case .refreshToken: return false
			default: return true
			}
		}
		
		var method: AIHTTPMethod {
			switch self {
			case .login,
					.requestCode,
					.refreshToken,
					.verifyCode,
					.registerUser,
					.modifyEmail,
					.modifyMobile,
					.addAddress,
					.modifyPassword,
					.submitFeedback,
					.bookPlan,
					.makeConsultationBooking
				:
				return .post
			case .getUser,
					.getAddresses,
					.about,
					.terms,
					.privacy,
					.getGoals,
					.getFilteredPlans,
					.getFitnessCategories,
					.getProfessionals,
					.getProfessionalAvailability,
					.getPlan,
					.getBookingDates,
					.getBookings
				:
				return .get
			case .uploadImage: return .multipart
			case .updateUser, .editAddress:
				return .put
			case .deleteAddress:
				return .delete
			}
		}
		
		var bodyParameters: Parameters? {
			switch self {
			case let .login(parameters): return parameters.dictionary!
			case let .updateUser(parameters): return parameters.dictionary!
			case let .requestCode(parameters): return parameters.dictionary!
			case let .verifyCode(parameters): return parameters.dictionary!
			case let .registerUser(parameters): return parameters.dictionary!
			case let .modifyEmail(parameters): return parameters.dictionary!
			case let .modifyMobile(parameters): return parameters.dictionary!
			case let .addAddress(parameters): return parameters.dictionary!
			case let .editAddress(parameters): return parameters.dictionary!
			case let .deleteAddress(parameters): return parameters.dictionary!
			case let .modifyPassword(parameters): return parameters.dictionary!
			case let .bookPlan(parameters): return parameters.dictionary!
			case let .makeConsultationBooking(parameters): return parameters.dictionary!
			default: return nil
			}
		}
		
		var queryParameters: Parameters? {
			switch self {
			case let .getFilteredPlans(parameters):
				var modifiedParameters = parameters.dictionary!
				if let goalID = modifiedParameters["goal_id"] as? String {
					modifiedParameters["goal_id"] = "\(goalID)"
				}
				return modifiedParameters
			case let .getProfessionals(parameters): return parameters.dictionary!
			case let .getProfessionalAvailability(parameters): return ["day": parameters.day,
																	   "month": parameters.month,
																	   "year": parameters.year]
			default: return nil
			}
		}
		
		var headers: HTTPHeaders? {
			switch self {
			case .getUser,
					.uploadImage,
					.updateUser,
					.modifyEmail,
					.modifyMobile,
					.getAddresses,
					.addAddress,
					.editAddress,
					.deleteAddress,
					.about,
					.terms,
					.submitFeedback,
					.getGoals,
					.getFilteredPlans,
					.getFitnessCategories,
					.getProfessionals,
					.getProfessionalAvailability,
					.getPlan,
					.bookPlan,
					.getBookingDates,
					.makeConsultationBooking,
					.getBookings
				:
				return .commonHeaders(authorization: .access)
			case .refreshToken:
				return .commonHeaders(authorization: .refresh)
			case .requestCode, .verifyCode, .modifyPassword:
				if Session.isLoggedIn {
					return .commonHeaders(authorization: .access)
				} else {
					return .commonHeaders()
				}
			default: return .commonHeaders()
			}
		}
		
		var endpoint: String? {
			switch self {
			case .login:
				return "user/login"
			case .getUser, .updateUser:
				return "user"
			case .refreshToken:
				return "user/refreshToken"
			case .uploadImage:
				return "upload/image"
			case .requestCode:
				return "auth/requestCode"
			case .verifyCode:
				return "auth/verifyCode"
			case .registerUser:
				return "user/register"
			case .modifyEmail:
				return "auth/modifyEmail"
			case .modifyMobile:
				return "auth/modifyMobile"
			case .getAddresses:
				return "user/address"
			case .addAddress:
				return "user/address"
			case .editAddress:
				return "user/address"
			case .deleteAddress:
				return "user/address"
			case .modifyPassword:
				return "auth/modifyPassword"
			case .about:
				return "misc/aboutUs"
			case .terms:
				return "misc/termsAndConditions"
			case .privacy:
				return "misc/privacyPolicy"
			case .submitFeedback:
				return "misc/submitFeedback"
			case .getGoals:
				return "plans/goals/all"
			case .getFilteredPlans:
				return "plans"
			case .getFitnessCategories:
				return "plans/fitnessCategories"
			case .getProfessionals:
				return "user/professionals"
			case let .getProfessionalAvailability(parameters):
				return "user/\(parameters.professional_id)/availability"
			case .getPlan:
				return "plan"
			case .bookPlan:
				return "plan/book"
			case .getBookingDates:
				return "booking/dates"
			case .makeConsultationBooking:
				return "booking/consultation"
			case .getBookings:
				return "bookings"
			}
		}
		
		var multipartFormData: MultipartFormData? {
			switch self {
			case let .uploadImage(parameters):
				let formData = MultipartFormData()
				
				var file_extension: String?
				var data: Data!
				if let temp_data = parameters.image.jpegData(compressionQuality: 0.5) {
					data = temp_data
					file_extension = "jpeg"
				} else if let temp_data = parameters.image.pngData() {
					data = temp_data
					file_extension = "png"
				} else {
					return nil
				}
				let fileName = "\(UUID().uuidString).\(file_extension ?? "")"
				guard let mimeType = parameters.image.mimeType else { return nil }
				
				formData.append(data, withName: "image", fileName: fileName, mimeType: mimeType)
				return formData
			default:
				return nil
			}
		}
	}
}
