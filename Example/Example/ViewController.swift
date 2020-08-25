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
        _ = AINetworkCalls.get(function: "get", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true, successCallback: { (json) in
            print("get json response: \(String(describing: json))")
        }) { (json, error) in
            print("get error json: \(String(describing: json))")
        }
        
        AINetworkCalls.rxGet(function: "get", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true).subscribe(onSuccess: { (json) in
            print("rxGet json response: \(String(describing: json))")
        }) { (error) in
            print("rxGet error: \(String(describing: error))")
        }.disposed(by: disposeBag)
    }
    
    func postAPITest() {
        let parameters = ["hand": "wave"]
        _ = AINetworkCalls.post(function: "post", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true, successCallback: { (json) in
            print("post json response: \(String(describing: json))")
        }) { (json, error) in
            print("post error: \(String(describing: json))")
        }
        
        AINetworkCalls.rxPost(function: "post", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true).subscribe(onSuccess: { (json) in
            print("rxPost json response: \(String(describing: json))")
        }) { (error) in
            print("rxPost error: \(String(describing: error))")
        }.disposed(by: disposeBag)
    }


}

