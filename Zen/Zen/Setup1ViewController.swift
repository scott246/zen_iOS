//
//  Setup1ViewController.swift
//  Zen
//
//  Created by Nathan Scott on 7/1/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class Setup1ViewController: UIViewController {
    
    @IBOutlet weak var totalAmount: UITextField!
    @IBAction func totalAmountChanged(_ sender: Any) {
        if totalAmount.text == "" {
            nextButton.isEnabled = false
        }
        else {
            nextButton.isEnabled = true
        }
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBAction func nextButtonClicked(_ sender: Any) {
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).child("account").setValue(Double(totalAmount.text!))
        self.performSegue(withIdentifier: "toSetup2", sender: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
    }
    
    override func viewDidLoad() {
        totalAmount.keyboardType = .numberPad
        nextButton.isEnabled = false
    }
}
