//
//  PaymentViewController.swift
//  Stellar Wallet
//
//  Created by Satraj Bambra on 2018-02-20.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    @IBAction func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
