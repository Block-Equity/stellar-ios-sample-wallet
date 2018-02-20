//
//  ViewController.swift
//  Stellar Wallet
//
//  Created by Satraj Bambra on 2018-02-20.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var generateAddressButton: UIButton!
    @IBOutlet var generateAddressView: UIView!
    
    @IBAction func generateAddress() {
        disableAddressButton()
        
        perform(#selector(self.enableAddressButton), with: nil, afterDelay: 2.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func disableAddressButton() {
        generateAddressButton.setTitle("", for: .normal)
        generateAddressButton.isEnabled = false
        activityIndicator.startAnimating()
    }
    
    @objc func enableAddressButton() {
        generateAddressButton.setTitle("Generate Stellar Address", for: .normal)
        generateAddressButton.isEnabled = true
        activityIndicator.stopAnimating()
    }
}

