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
import UserNotifications

class BalanceViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    @IBOutlet var generateAddressButton: UIButton!
    @IBOutlet var generateAddressImageView: UIImageView!
    @IBOutlet var generateAddressView: UIView!
    
    let sdk = StellarSDK()
    var isNotificationAccessGranted: Bool = false
    
    @IBAction func generateAddress() {
        disableAddressButton()
        
        generateWalletAddress()
    }
    
    @IBAction func copyAddress() {
        if let addressText = addressLabel.text, !addressText.isEmpty {
            UIPasteboard.general.string = addressLabel.text
            
            let alert = UIAlertController(title: "Your Stellar wallet address has been successfully copied!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForPrexistingWallet()
        checkForPushPermissions()
    }
    
    func checkForPushPermissions() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert,.sound,.badge],
            completionHandler: { (granted,error) in
                self.isNotificationAccessGranted = granted
            }
        )
    }
    
    func checkForPrexistingWallet() {
        if let accountId =  UserDefaults.standard.string(forKey: "accountId") {
            disableAddressButton()
            getAccountDetails(accountId: accountId)
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
 * Stellar SDK functions.
 */
extension BalanceViewController {
    func generateWalletAddress() {
        let keyPair = try! KeyPair.generateRandomKeyPair()
        
        sdk.accounts.createTestAccount(accountId: keyPair.accountId) { (response) -> (Void) in
            switch response {
            case .success(let data):
                print("Details: \(data)")
                let publicData = NSData(bytes: keyPair.publicKey.bytes, length: keyPair.publicKey.bytes.count)
                
                let privateBytes = keyPair.privateKey?.bytes ?? [UInt8]()
                let privateData = NSData(bytes: privateBytes, length: privateBytes.count)

                // Saving to user defaults is just for testing. This will be transferred to the keychain in an upcoming update.
                UserDefaults.standard.set(keyPair.accountId, forKey: "accountId")
                UserDefaults.standard.set(publicData, forKey: "publicKey")
                UserDefaults.standard.set(privateData, forKey: "privateKey")
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
                    self.streamBalance(accountId: stellarAccountId)
                }
                
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.enableAddressButton()
                }
            }
        }
    }
    
    func streamBalance(accountId: String) {
        sdk.payments.stream(for: .paymentsForAccount(account: accountId, cursor: nil)).onReceive { (response) -> (Void) in
            switch response {
            case .open:
                break
            case .response( _, let paymentResponse):

                if paymentResponse.sourceAccount != accountId {
                    let title = "Payment Received"
                    let body = "You just received a payment of \(paymentResponse.amount) XLM from \(paymentResponse.sourceAccount)"
                    
                    self.displayPushNotification(with: title, body: body)
                } 
                self.getAccountDetails(accountId: accountId)
            case .error( _):
                break
            }
        }
    }
}

/*
 * Display the push notification.
 */
extension BalanceViewController {
    func displayPushNotification(with title: String, body: String) {
        if (isNotificationAccessGranted) {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 0.5,
                repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "payment",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

/*
 * Delegate required for push notification display when app is in foreground.
 */
extension BalanceViewController : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}


