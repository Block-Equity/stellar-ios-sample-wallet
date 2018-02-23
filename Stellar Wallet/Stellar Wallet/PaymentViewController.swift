//
//  PaymentViewController.swift
//  Stellar Wallet
//
//  Created by Satraj Bambra on 2018-02-20.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk

import UIKit

class PaymentViewController: UIViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var addressTextfield: UITextField!
    @IBOutlet var paymentTextfield: UITextField!
    @IBOutlet var sendPaymentButton: UIButton!
    
    let sdk = StellarSDK()
    
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

        disableSendPaymentButton()
        signAndPostPaymentTransaction(to: addressText, amount: Decimal(floatLiteral: Double(paymentText)!))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        paymentTextfield.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func disableSendPaymentButton() {
        sendPaymentButton.setTitle("", for: .normal)
        sendPaymentButton.isEnabled = false
        addressTextfield.isEnabled = false
        paymentTextfield.isEnabled = false
        activityIndicator.startAnimating()
    }
    
    func enableSendPaymentButton() {
        sendPaymentButton.setTitle("Send Payment", for: .normal)
        sendPaymentButton.isEnabled = true
        addressTextfield.isEnabled = true
        paymentTextfield.isEnabled = true
        activityIndicator.stopAnimating()
    }
}

/**
 * Scan view delegate functions.
 */
extension PaymentViewController: ScanViewControllerDelegate {
    func setQR(value: String) {
        addressTextfield.text = value
    }
}

/**
 * Stellar SDK functions.
 */
extension PaymentViewController {
    func signAndPostPaymentTransaction(to accountId: String, amount: Decimal) {
        if let privateKeyData =  UserDefaults.standard.data(forKey: "privateKey"), let publicKeyData =  UserDefaults.standard.data(forKey:"publicKey")  {
            
            let publicBytes: [UInt8] = [UInt8](publicKeyData)
            let privateBytes: [UInt8] = [UInt8](privateKeyData)

            let sourceKeyPair = try! KeyPair(publicKey: PublicKey(publicBytes), privateKey: PrivateKey(privateBytes))
            let destinationKeyPair = try! KeyPair(publicKey: PublicKey.init(accountId: accountId), privateKey: nil)
            
            sdk.accounts.getAccountDetails(accountId: sourceKeyPair.accountId) { (response) -> (Void) in
            switch response {
                case .success(let accountResponse):
                    do {
                        let paymentOperation = PaymentOperation(sourceAccount: sourceKeyPair,
                                                                destination: destinationKeyPair,
                                                                asset: Asset(type: AssetType.ASSET_TYPE_NATIVE)!,
                                                                amount: amount)
                        let transaction = try Transaction(sourceAccount: accountResponse,
                                                          operations: [paymentOperation],
                                                          memo: Memo.none,
                                                          timeBounds:nil)
                        try transaction.sign(keyPair: sourceKeyPair, network: Network.testnet)
                        
                        try self.sdk.transactions.submitTransaction(transaction: transaction) { (response) -> (Void) in
                            switch response {
                                case .success(_):
                                    print("Transaction successful.")
                                    DispatchQueue.main.async {
                                        self.perform(#selector(self.dismissView), with: nil, afterDelay: 1.0)
                                    }
                                case .failure(_):
                                    break
                            }
                        }
                    }
                    catch {
                        print("Transaction failed.")
                        self.enableSendPaymentButton()
                        
                    }
                case .failure(let error):
                    print(error)
                    self.enableSendPaymentButton()
                }
            }
        }
    }
}
