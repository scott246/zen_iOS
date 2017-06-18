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
var cycle = "Continuously"

class SettingsViewController: UITableViewController, CurrencyDataEnteredDelegate, CycleDataEnteredDelegate {
    
    var user: User!
    var ref: DatabaseReference!
    private var databaseHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Settings"
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        currencyLabel.text = currency
        cycleLabel.text = cycle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 && indexPath.section == 0 { //reset cycle button
            //show an alert
            let alert = UIAlertController(title: "Reset Cycles", message: "Are you sure you want to reset all data from this cycle?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
                //delete all data
                print("cycles reset")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        if indexPath.row == 2 && indexPath.section == 1 { //logout button
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                present(vc, animated: true, completion: nil)
            } catch {
                print("couldn't sign out")
            }
        }
        if indexPath.row == 0 && indexPath.section == 2 { //reset data button
            //show an alert
            let alert = UIAlertController(title: "Warning!", message: "Are you sure you want to reset all your data?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive, handler: { action in
                //delete all data
                self.ref.child("users/\(self.user.uid)/transactions").removeValue()
                print("data reset")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var cycleLabel: UILabel!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCurrencySelector" {
            let currencyVC = segue.destination as! CurrencySelectorViewController
            currencyVC.delegate = self
        }
        if segue.identifier == "showCycleSelector" {
            let cycleVC = segue.destination as! CycleDurationViewController
            cycleVC.delegate = self
        }
    }
    
    func userDidEnterCurrencyInformation(info: String) {
        currencyLabel.text = info
        currency = info
        self.ref.child("users").child(self.user.uid).child("currency").setValue(info)
    }
    func userDidEnterCycleInformation(info: String) {
        cycleLabel.text = info
        cycle = info
        self.ref.child("users").child(self.user.uid).child("cycle").setValue(info)
    }
    
}

