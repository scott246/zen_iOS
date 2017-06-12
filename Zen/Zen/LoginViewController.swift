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
    }
    @IBAction func aboutButton(_ sender: AnyObject) {
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

