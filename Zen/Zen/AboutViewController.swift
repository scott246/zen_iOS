//
//  AboutViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/11/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AboutViewController: UIViewController {
    
    @IBOutlet weak var backToLoginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if Auth.auth().currentUser != nil{
            backToLoginButton.isHidden = true
        }
        else {
            backToLoginButton.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
