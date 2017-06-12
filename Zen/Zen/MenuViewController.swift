//
//  MenuViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/10/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MenuViewController: UIViewController {

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
    

    @IBAction func budgetButton(_ sender: Any) {
    }
    @IBAction func recordsButton(_ sender: Any) {
    }
    @IBAction func calendarButton(_ sender: Any) {
    }

    @IBAction func logoutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logout", sender: nil)
        } catch {
            print("sign out error")
        }
    }
    @IBAction func settingsButton(_ sender: Any) {
        self.performSegue(withIdentifier: "settings", sender: nil)
    }
    
    func getEmail() -> String {
        return (Auth.auth().currentUser?.email)!
    }
    
    
}
