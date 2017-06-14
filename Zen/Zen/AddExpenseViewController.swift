//
//  AddExpenseViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/13/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

// protocol used for sending data back
protocol ExpenseDataEnteredDelegate: class {
    func userDidEnterAmountInformation(info: String)
    func userDidEnterCategoryInformation(info:String)
    func userDidEnterDateInformation(info:String)
    func userDidEnterNoteInformation(info:String)
    func userDidEnterRecurringInformation(info:Bool)
}

class AddExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    weak var delegate: ExpenseDataEnteredDelegate? = nil
    
    var pickerFields = ["Uncategorized", "Automotive", "Bills", "Coffee", "Clothing", "Children", "Donations", "Drinks", "Education", "Entertainment", "Family", "Fitness", "Food", "Games", "Gas", "General", "Gifts", "Groceries", "Haircuts", "Health", "Hobbies", "Household", "Laundry", "Leisure", "Loan", "Motorcycle", "Music", "Other", "Payment", "Personal", "Pets", "Restaurant", "Shopping", "Significant Other", "Smoking", "Social", "Tools", "Transportation", "Travel", "Treats", "Vacations", "Work"];
    
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerFields.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerFields[row]
    }
    
    @IBOutlet weak var recurringExpenseLabel: UILabel!
    @IBOutlet weak var recurringSwitch: UISwitch!
    @IBOutlet weak var noteField: UITextField!
    @IBOutlet weak var amountField: UITextField!
    @IBAction func amountEntered(_ sender: Any) {
        amount = amountField.text!
    }
    @IBAction func noteEntered(_ sender: Any) {
        note = noteField.text!
    }
    @IBAction func recurringExpenseChanged(_ sender: Any) {
        if recurringSwitch.isOn {recurringExpense = true}
        else {recurringExpense = false}
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func datePickerChanged(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        date = formatter.string(from: datePicker.date)
    }
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBAction func segmenterChanged(_ sender: Any) {
        if segmenter.selectedSegmentIndex == 0 {
            categoryPicker.isHidden = true
            datePicker.isHidden = true
            noteField.isHidden = false
            amountField.isHidden = false
            recurringSwitch.isHidden = false
            recurringExpenseLabel.isHidden = false
        }
        else if segmenter.selectedSegmentIndex == 1 {
            categoryPicker.isHidden = true
            datePicker.isHidden = false
            noteField.isHidden = true
            amountField.isHidden = true
            recurringSwitch.isHidden = true
            recurringExpenseLabel.isHidden = true
        }
        else if segmenter.selectedSegmentIndex == 2 {
            categoryPicker.isHidden = false
            datePicker.isHidden = true
            noteField.isHidden = true
            amountField.isHidden = true
            recurringSwitch.isHidden = true
            recurringExpenseLabel.isHidden = true
        }
    }
    @IBOutlet weak var segmenter: UISegmentedControl!
    
    var user: User!
    var ref: DatabaseReference!
    
    var amount:String = ""
    var note:String = ""
    var recurringExpense = false
    var date:String = ""
    var category:String = "Uncategorized"
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amountField.delegate = self
        amountField.keyboardType = .numberPad
        
        self.categoryPicker.dataSource = self;
        self.categoryPicker.delegate = self;
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(returnToRecords)), animated: true)
        
        categoryPicker.isHidden = true
        datePicker.isHidden = true
        
        let day = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let today = formatter.string(from: day)
        date = today

    }
    
    func returnToRecords() {
        //amount = String(describing: Double(amountField.text!))
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        var amt = 0.0
        amt = (amountField.text! as NSString).doubleValue
        amount = formatter.string(from: NSNumber(value: amt))!
        //amount = String(describing: (amountField.text! as NSString).doubleValue.)
        if (amount != "") {
            delegate?.userDidEnterDateInformation(info: date)
            note = noteField.text!
            delegate?.userDidEnterNoteInformation(info: note)
            delegate?.userDidEnterAmountInformation(info: amount)
            category = pickerFields[categoryPicker.selectedRow(inComponent: 0)]
            delegate?.userDidEnterCategoryInformation(info: category)
            delegate?.userDidEnterRecurringInformation(info: recurringExpense)
            _ = self.navigationController?.popViewController(animated: true)
        }
        else {
            let alert = UIAlertController(title: "Amount Missing", message: "The amount field is required.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
