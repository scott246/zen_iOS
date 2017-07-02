//
//  ViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/10/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    // MARK: outlets
    //email text field
    @IBOutlet weak var emailTextField: UITextField!
    //password text field
    @IBOutlet weak var passwordTextField: UITextField!
    //registration success/failure label
    @IBOutlet weak var regSuccessLabel: UILabel!
    
    // MARK: login screen buttons
    //button for registration
    @IBAction func registerButton(_ sender: AnyObject) {
        //first take email and password from views
        let email = emailTextField.text
        let password = passwordTextField.text
        
        //use firebase authorization
        Auth.auth().createUser(withEmail: email!, password: password!, completion: { (user: User?, error) in
            if error == nil {
                self.regSuccessLabel.text = "Registered as \(email ?? "a user")."
                Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)").updateChildValues([
                    "currency": "$",
                    "cycle": "Monthly",
                    "lastlogin": "0",
                    "savings": 20,
                    "account": 0.00,
                    "goals": []])
            }else{
                self.regSuccessLabel.text = error?.localizedDescription
            }
        })
    }
    @IBAction func loginButton(_ sender: AnyObject) {
        //first take email and password from view
        let email = emailTextField.text
        let password = passwordTextField.text
        
        //use firebase authorization
        Auth.auth().signIn(withEmail: email!, password: password!, completion: { (user: User?, error) in
            if error == nil {
                
            } else {
                self.regSuccessLabel.text = error?.localizedDescription
            }
        })
    }
    @IBAction func fpButton(_ sender: AnyObject) {
    }
    @IBAction func aboutButton(_ sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Login"
        self.restorationIdentifier = "Login"
        //FirebaseApp.configure()
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                //do {
                //    try Auth.auth().signOut()
                //}
                //catch {
                //    print("i give up")
                //}
                // User is signed in.
                var ll = "0"
                var ac: Float = 0.00
                let userID = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
                    let value = snapshot.value as? NSDictionary
                    ll = value?["lastlogin"] as? String ?? "0"
                    ac = value?["account"] as? Float ?? 0.00
                    if ll != "0" && ac != 0.00 {
                        self.performSegue(withIdentifier: "login", sender: nil)
                    }
                    else {
                        Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)").updateChildValues([
                            "currency": "$",
                            "cycle": "Monthly",
                            "lastlogin": "0",
                            "savings": 20,
                            "account": 0.00,
                            "goals": []])
                        let dict: Dictionary<String, Float> = [
                            "Automotive & Transportation": 100.00,
                            "Bills & Utilities": 1000.00,
                            "Business Services": 100.00,
                            "Charges & Fees": 0.00,
                            "Donations & Gifts": 10.00,
                            "Drinks & Social": 50.00,
                            "Education": 100.00,
                            "Entertainment": 50.00,
                            "Family & Children": 100.00,
                            "Food & Restaurants": 300.00,
                            "Health & Fitness": 100.00,
                            "Home": 100.00,
                            "Investments": 50.00,
                            "Payments & Loans": 300.00,
                            "Personal": 50.00,
                            "Pets": 50.00,
                            "Shopping": 200.00,
                            "Taxes": 50.00,
                            "Travel": 100.00,
                            "Other": 500.00
                        ]
                        Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)/goals").updateChildValues(dict)
                        self.performSegue(withIdentifier: "setup", sender: nil)
                    }
                }) { (error) in
                    print(error.localizedDescription)
                }
            } else {
                // No user is signed in.
                
            }
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

