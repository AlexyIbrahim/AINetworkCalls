//
//  ViewController.swift
//  Example
//
//  Created by Alexy Ibrahim on 8/23/20.
//  Copyright © 2020 Alexy Ibrahim. All rights reserved.
//

import UIKit
import AINetworkCalls
import SwiftyJSON
import Alamofire
import Promises


class ViewController: MasterViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        self.getAPITest()
        self.postAPITest()
    }
    
    func getAPITest() {
        let parameters = ["foo1": "bar1",
                          "foo2": "bar2"]
        
        _ = AINetworkCalls.get(endpoint: .main, function: "get", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true, successCallback: { (response: GetResponseModel) in
            print("get json response: \(String(describing: response))")
        }) { (json, error) in
            print("get error json: \(String(describing: json))")
        }
    }
    
    public struct PostRequest: Codable {
        let hand: String
    }

    enum PostContract: AIServiceModule {
        case postMethod(paramters: PostRequest)
        
        var method: AIHTTPMethod {
            switch self {
            case .postMethod: return .post
            }
        }
        
        var bodyParameters: Parameters? {
            switch self {
            case .postMethod(let parameters): return parameters.asDictionary()
            }
        }
        
        var aiEndPoint: AIEndPoint {
            switch self {
            case .postMethod: return .init(module: .main, function: "post")
            }
        }
    }
    
    func postAPITest() {
        let contract = PostContract.postMethod(paramters: .init(hand: "wave"))
        let wrapper = AIServiceWrapper.init(module: contract)
        AIContractInterceptor.request(wrapper: wrapper) { (response: JSON) in
            print("post json response: \(String(describing: response))")
        } errorCallback: { json, error in
            print("post error: \(String(describing: json))")
        }

        /* Using Promises
		AIContractInterceptor.request(wrapper: wrapper, objectType: JSON.self).then(on: .main) { value in
			print("post json response: \(String(describing: value))")
		}.catch(on: .main) { error in
			print("post error: \(String(describing: error))")
		}
		*/
         
    }
}

