//
//  PINEntryViewController.swift
//  Zen
//
//  Created by Nathan Scott on 7/15/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class PINEntryViewController: UIViewController {
    
    var incorrectGuesses = 0
    
    @IBOutlet weak var errorField: UILabel!
    @IBOutlet weak var PINEntryField: UITextField!
    @IBAction func PINChanged(_ sender: Any) {
        if PINEntryField.text?.characters.count == 4 {
            let userID = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? NSDictionary
                if self.PINEntryField.text?.sha256() == value?["PIN"] as? String ?? "" {
                    self.performSegue(withIdentifier: "authPIN", sender: nil)
                }
                else {
                    self.incorrectGuesses += 1
                    self.errorField.isHidden = false
                    self.errorField.text = "Incorrect PIN. \(3-self.incorrectGuesses) attempt(s) remaining."
                    if self.incorrectGuesses >= 3 {
                        do {
                            try Auth.auth().signOut()
                            self.dismiss(animated: true, completion: nil)
                        } catch {
                            print("i give up")
                            exit(0)
                        }
                    }
                }
            })
            PINEntryField.text = ""
        }

    }
    
    override func viewDidLoad() {
        self.PINEntryField.becomeFirstResponder()
        self.errorField.isHidden = true
    }
}
