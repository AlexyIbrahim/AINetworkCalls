//
//  ViewController.swift
//  Example
//
//  Created by Alexy Ibrahim on 8/23/20.
//  Copyright © 2020 Alexy Ibrahim. All rights reserved.
//

import UIKit
import AINetworkCalls
import RxSwift
import SwiftyJSON


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
        
        /* Using RxSwift
        AINetworkCalls.rxGet(endpoint: .main, function: "get", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true).subscribe(onSuccess: { (response: GetResponseModel) in
            print("rxGet json response: \(String(describing: response))")
        }) { (error) in
            print("rxGet error: \(String(describing: error))")
        }.disposed(by: disposeBag)
        */
    }
    
    func postAPITest() {
        let parameters = ["hand": "wave"]
        _ = AINetworkCalls.post(endpoint: .main, function: "post", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true, successCallback: { (response: JSON) in
            print("post json response: \(String(describing: response))")
        }) { (json, error) in
            print("post error: \(String(describing: json))")
        }
        
        /* Using RxSwift
        AINetworkCalls.rxPost(endpoint: .main, function: "post", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true).subscribe(onSuccess: { (response: JSON) in
            print("rxPost json response: \(String(describing: json))")
        }) { (error) in
            print("rxPost error: \(String(describing: error))")
        }.disposed(by: disposeBag)
         */
    }


}

