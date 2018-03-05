//
//  MnemonicViewController.swift
//  Stellar Wallet
//
//  Created by Satraj Bambra on 2018-03-05.
//  Copyright © 2018 Satraj Bambra. All rights reserved.
//

import stellarsdk

import UIKit

class MnemonicViewController: UIViewController {
    
    @IBOutlet var leftViewHolder: UIView!
    @IBOutlet var rightViewHolder: UIView!
    
    @IBAction func dismissView() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        generateMnemonic()
    }
    
    func setupView() {
        navigationItem.title = "Your 24 word phrase"
    }
    
    func generateMnemonic() {
        let mnemonic = Mnemonic.create(strength: .high, language: .english)
        
        let menmonicArray = mnemonic.split(separator: " ")
        print(menmonicArray.count, menmonicArray)
        
        let leftMnemonicArray =  menmonicArray.split().left
        let rightMnemonicArray = menmonicArray.split().right
        
        for index in 0...leftMnemonicArray.count - 1 {
            let label = UILabel(frame: CGRect(origin: CGPoint(x: 15.0, y: leftViewHolder.frame.size.height / 12 * CGFloat(index)), size: CGSize(width: leftViewHolder.frame.size.width - 30.0, height: leftViewHolder.frame.size.height / 12)))
            label.textAlignment = .left
            label.text = "\(index + 1). \(leftMnemonicArray[index])"
            leftViewHolder.addSubview(label)
        }
        
        for index in 0...rightMnemonicArray.count - 1 {
            let label = UILabel(frame: CGRect(origin: CGPoint(x: 0.0, y: rightViewHolder.frame.size.height / 12 * CGFloat(index)), size: CGSize(width: rightViewHolder.frame.size.width - 15.0, height: rightViewHolder.frame.size.height / 12)))
            label.textAlignment = .left
            label.text = "\(index + 13). \(rightMnemonicArray[index])"
            rightViewHolder.addSubview(label)
        }
    }
}

extension Array {
    func split() -> (left: [Element], right: [Element]) {
        let ct = self.count
        let half = ct / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< ct]
        return (left: Array(leftSplit), right: Array(rightSplit))
    }
}

