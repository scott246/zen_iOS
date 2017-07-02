//
//  Setup3ViewController.swift
//  Zen
//
//  Created by Nathan Scott on 7/1/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class Setup3ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var welcomeToZen: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var expensePicker: UIPickerView!
    @IBOutlet weak var goalField: UITextField!
    @IBAction func goalFieldChanged(_ sender: Any) {
        Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)/goals").updateChildValues([labels[expensePicker.selectedRow(inComponent: 0)] : Float(goalField.text!) ?? 0])
    }
    
    var labels = ["Automotive & Transportation", "Bills & Utilities", "Business Services", "Charges & Fees", "Donations & Gifts", "Drinks & Social", "Education", "Entertainment", "Family & Children", "Food & Restaurants", "Health & Fitness", "Home", "Investments", "Payments & Loans", "Personal", "Pets", "Shopping", "Taxes", "Travel", "Other"]
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return labels.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return labels[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let userID = Auth.auth().currentUser?.uid
        var l: Float = 0.00
        Database.database().reference().child("users").child(userID!).child("goals").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            l = value?[self.labels[row]] as? Float ?? 0.00
            self.goalField.text = String(describing: l)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.expensePicker.delegate = self
        self.expensePicker.dataSource = self
        goalField.keyboardType = .numberPad
        let userID = Auth.auth().currentUser?.uid
        var l: Float = 0.0
        Database.database().reference().child("users").child(userID!).child("goals").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            l = value?[self.labels[0]] as? Float ?? 0.00
            self.goalField.text = String(describing: l)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
