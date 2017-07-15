//
//  SettingsViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/11/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

var currency = "$"
var PINEnabled = false

class SettingsViewController: UITableViewController, CurrencyDataEnteredDelegate {
    
    var user: User!
    var ref: DatabaseReference!
    private var databaseHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(red: 60/255, green: 180/255, blue: 60/255, alpha: 0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 180/255, blue: 60/255, alpha: 0)
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        tabBarController?.tabBar.tintColor = UIColor.white
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Settings"
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        currencyLabel.text = currency
        if (PINEnabled) {
            while tableView.numberOfRows(inSection: 1) < 1 {
                continue
            }
            tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.accessoryType = .checkmark
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 && indexPath.section == 0 { //logout button
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(vc, animated: true, completion: nil)
            } catch {
                print("couldn't sign out")
            }
        }
        if indexPath.row == 0 && indexPath.section == 1 { //PIN button
            if let cell = tableView.cellForRow(at: indexPath) {
                
                if cell.accessoryType == .checkmark {
                    PINEnabled = false
                    Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/PINEnabled").setValue(false)
                    Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/PIN").setValue("")
                    cell.accessoryType = .none
                    tableView.deselectRow(at: indexPath, animated: true)
                }
                else {
                    cell.accessoryType = .checkmark
                    PINEnabled = true
                    Database.database().reference().child("users/\(Auth.auth().currentUser!.uid)/PINEnabled").setValue(true)
                    performSegue(withIdentifier: "setPIN", sender: nil)
                }
            }
        }
        if indexPath.row == 0 && indexPath.section == 2 { //reset data button
            //show an alert
            let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to reset all your data?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { action in
                //delete all data
                self.ref.child("users/\(self.user.uid)/transactions").removeValue()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var currencyLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCurrencySelector" {
            let currencyVC = segue.destination as! CurrencySelectorViewController
            currencyVC.delegate = self
        }
    }
    
    func userDidEnterCurrencyInformation(info: String) {
        currencyLabel.text = info
        currency = info
        self.ref.child("users").child(self.user.uid).child("currency").setValue(info)
    }
    
}

