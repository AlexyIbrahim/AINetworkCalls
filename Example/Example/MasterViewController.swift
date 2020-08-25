//
//  MasterViewController.swift
//  Fibler2
//
//  Created by Alexy Ibrahim on 1/1/20.
//  Copyright © 2020 siegma. All rights reserved.
//

import UIKit
import RxSwift

class MasterViewController: UIViewController {

    internal let disposeBag = DisposeBag()
    var isDismissingCallback:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed {
            if let isDismissingCallback = isDismissingCallback {
                isDismissingCallback()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
}
