//
//  BudgetViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/10/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class BudgetViewController: UIViewController {

    @IBOutlet weak var emailDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailDisplay.text = "\(getEmail())"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getEmail() -> String {
        return (Auth.auth().currentUser?.email)!
    }
    
    
}
