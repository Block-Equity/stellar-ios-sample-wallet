//
//  PaymentViewController.swift
//  Stellar Wallet
//
//  Created by Satraj Bambra on 2018-02-20.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
    
    @IBOutlet var addressTextfield: UITextField!
    @IBOutlet var paymentTextfield: UITextField!
    
    @IBAction func dismissView() {
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scanCode() {
        let scanViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ScanViewController") as! ScanViewController
        scanViewController.delegate = self
        present(scanViewController, animated: false, completion: nil)
    }
    
    @IBAction func sendPayment() {
        guard let addressText = addressTextfield.text, !addressText.isEmpty else {
            return
        }
        
        guard let paymentText = paymentTextfield.text, !paymentText.isEmpty else {
            return
        }
        
        print(addressText, paymentText)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        paymentTextfield.becomeFirstResponder()
    }
}

extension PaymentViewController: ScanViewControllerDelegate {
    func setQR(value: String) {
        addressTextfield.text = value
    }
}
