//
//  PasswordResetViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/11/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class PasswordResetViewController: UIViewController {
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    @IBAction func sendEmailButton(_ sender: Any) {
        let email = emailField.text
        
        Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
            if error != nil {
                print(error.debugDescription)
                self.infoLabel.text = error?.localizedDescription
            } else {
                self.infoLabel.text = "Password reset email sent to \(email ?? "your email address")."
            }
        }
    }
    @IBAction func backToLogin(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        background.image = UIImage(named:"Image")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
