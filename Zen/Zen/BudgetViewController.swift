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
import FirebaseDatabase


class BudgetViewController: UIViewController {
    var user: User!
    var ref: DatabaseReference!

    @IBOutlet weak var emailDisplay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailDisplay.text = "\(getEmail())"
        
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        
        var curr: String = ""
        
        ref.child("users").child(self.user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as! NSDictionary
            curr = value["currency"] as? String ?? ""
        }) { (error) in
            print(error.localizedDescription)
        }
        
        if curr == "" {
            self.ref.child("users").child(self.user.uid).child("currency").setValue("$")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getEmail() -> String {
        return (Auth.auth().currentUser?.email)!
    }
    
    
}
