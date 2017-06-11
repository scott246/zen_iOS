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
                self.regSuccessLabel.text = "Registration success!"
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
                self.performSegue(withIdentifier: "login", sender: nil)
            } else {
                self.regSuccessLabel.text = error?.localizedDescription
            }
        })
    }
    @IBAction func fpButton(_ sender: AnyObject) {
        let email = emailTextField.text
        
        Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
            if error != nil {
                self.regSuccessLabel.text = error?.localizedDescription
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //FirebaseApp.configure()
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                // User is signed in.
                self.performSegue(withIdentifier: "login", sender: nil)
            } else {
                // No user is signed in.
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

