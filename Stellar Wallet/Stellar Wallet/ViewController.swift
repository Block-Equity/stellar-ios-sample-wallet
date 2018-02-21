//
//  ViewController.swift
//  Stellar Wallet
//
//  Created by Satraj Bambra on 2018-02-20.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import CoreImage
import stellarsdk
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var generateAddressButton: UIButton!
    @IBOutlet var generateAddressImageView: UIImageView!
    @IBOutlet var generateAddressView: UIView!
    
    let sdk = StellarSDK()
    
    @IBAction func generateAddress() {
        disableAddressButton()
        
        generateWalletAddress()
    }
    
    @IBAction func displaySendCurrencyController() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForPrexistingWallet()
    }
    
    func checkForPrexistingWallet() {
        if let publicKey =  UserDefaults.standard.string(forKey: "publicKey") {
            disableAddressButton()
            getAccountDetails(accountId: publicKey)
        }
    }

    func disableAddressButton() {
        generateAddressButton.setTitle("", for: .normal)
        generateAddressButton.isEnabled = false
        activityIndicator.startAnimating()
    }
    
    func enableAddressButton() {
        generateAddressButton.setTitle("Generate Stellar Address", for: .normal)
        generateAddressButton.isEnabled = true
        activityIndicator.stopAnimating()
    }
    
    func displayGeneratedAddress(with balance: String, stellarAccountId: String) {
        let data = stellarAccountId.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        let qrcodeImage = filter?.outputImage
        let scaleX = generateAddressImageView.frame.size.width / (qrcodeImage?.extent.size.width)!
        let scaleY = generateAddressImageView.frame.size.height / (qrcodeImage?.extent.size.height)!
        let transformedImage = qrcodeImage?.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        generateAddressImageView.image = UIImage(ciImage: transformedImage!)
        
        addressLabel.text = stellarAccountId
        balanceLabel.text = balance
        
        generateAddressView.isHidden = true
        
        enableAddressButton()
    }
}

/**
 * Stellar SDK functions 
 */
extension ViewController {
    func generateWalletAddress() {
        let keyPair = try! KeyPair.generateRandomKeyPair()
        
        sdk.accounts.createTestAccount(key: keyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let data):
                print("Details: \(data)")
                UserDefaults.standard.set(keyPair.accountId, forKey: "publicKey")
                self.getAccountDetails(accountId: keyPair.accountId)
                
            case .failure(let error):
                print("Error: \(error)")
                self.enableAddressButton()
            }
        }
    }
    
    func getAccountDetails(accountId: String) {
        sdk.accounts.getAccountDetails(accountId: accountId) { (response) -> (Void) in
            switch response {
            case .success(let accountDetails):
                print("Details: \(accountDetails.accountId, accountDetails.balances[0].balance)")
                
                DispatchQueue.main.async {
                    let stellarAccountId = accountDetails.accountId
                    self.displayGeneratedAddress(with: accountDetails.balances[0].balance, stellarAccountId: stellarAccountId)
                }
                
            case .failure(let error):
                print("Error: \(error)")
                self.enableAddressButton()
            }
        }
    }
}

