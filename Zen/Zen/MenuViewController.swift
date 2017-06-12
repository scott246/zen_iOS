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

class MenuViewController: UIViewController{
    
    /*
     TODO apps
     budget
     calculator
     calendar
     clock
     contacts
     diary
     email
     list
     medical tracker
     messages
     news
     notes
     reminders
     system info
     tasks
     weather
    */
    var apps = [
        ("Note"), ("List"), ("Task")
    ]
    
    @IBOutlet weak var emailDisplay: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Zen"
        emailDisplay.text = "\(getEmail())"
        imageView.image = UIImage(named:"Image")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
