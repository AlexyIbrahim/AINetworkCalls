//
//  ViewController.swift
//  Example
//
//  Created by Alexy Ibrahim on 8/23/20.
//  Copyright © 2020 Alexy Ibrahim. All rights reserved.
//

import UIKit
import AINetworkCalls

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                
        self.getAPITest()
        self.postAPITest()
        
    }
    
    func getAPITest() {
        let parameters = ["foo1": "bar1",
                          "foo2": "bar2"]
        AINetworkCalls.get(fullPath: "https://postman-echo.com/get", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true, successCallback: { (json) in
            print("json response: \(String(describing: json))")
        }) { (json, error) in
            print("error json: \(String(describing: json))")
        }
    }
    
    func postAPITest() {
        let parameters = ["hand": "wave"]
        AINetworkCalls.post(fullPath: "https://postman-echo.com/post", headers: nil, encoding: .default, parameters: parameters, displayWarnings: true, successCallback: { (json) in
            print("json: \(String(describing: json))")
        }) { (json, error) in
            print("error json: \(String(describing: json))")
        }
    }


}

