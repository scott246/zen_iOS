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

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var apps = [
        ("Note"), ("List"), ("Task")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Zen (\(getEmail()))"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apps.count
    }
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "appCell", for: indexPath as IndexPath) as UITableViewCell
        cell.textLabel?.text = apps[indexPath.row]
        cell.detailTextLabel?.text = "0" //replace with number of notes, tasks, etc
        return cell
    }
    
    @IBOutlet weak var myTableView: UITableView! {
        didSet {
            myTableView.dataSource = self
        }
    }

    @IBAction func logoutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "logout", sender: nil)
        } catch {
            print("sign out error")
        }
    }
    
    func getEmail() -> String {
        return (Auth.auth().currentUser?.email)!
    }
    
    
    
}
