import AINetworkCalls
import Alamofire
import Promises
import SwiftyJSON
import UIKit

class ViewController: MasterViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		
		//		getAPITest()
//		postAPITest()
		errorTest()
	}
	
	//	func getAPITest() {
	//		let parameters = ["foo1": "bar1",
	//						  "foo2": "bar2"]
	//
	//		_ = AINetworkCalls.get(baseUrl: <#T##BaseUrl#>: .main, function: "get", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true, successCallback: { (response: GetResponseModel) in
	//			print("get json response: \(String(describing: response))")
	//		}) { json, _ in
	//			print("get error json: \(String(describing: json))")
	//		}
	//	}
	
	func postAPITest() {
		APICalls.postMethod(paramters: .init(hand: "wave")).execute().then { response in
			print("post json response: \(String(describing: response))")
		}.catch { error in
			print("post error: \(String(describing: error))")
		}
	}
	
	func errorTest() {
		APICalls.error.execute().then { response in
			print("error json response: \(String(describing: response))")
		}.catch { error in
			print("error error: \(String(describing: error))")
		}
	}
}
