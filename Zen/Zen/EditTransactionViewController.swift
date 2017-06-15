//
//  EditTransactionViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/14/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

// protocol used for sending data back
protocol EditDataEnteredDelegate: class {
    func userDidChangeAmountInformation(info: String)
    func userDidChangeCategoryInformation(info: String)
    func userDidChangeDateInformation(info: String)
    func userDidChangeNoteInformation(info: String)
    func userDidChangeRecurringInformation(info: Bool)
    func userDidChangeTypeInformation(info: String)
}

class EditTransactionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var type: String!
    var amount: String!
    var category: String = "Uncategorized"
    var date: String!
    var note: String!
    var recurring: Bool!
    
    weak var delegate: EditDataEnteredDelegate? = nil
    
    var expenseFields = ["Uncategorized", "Automotive", "Bills", "Coffee", "Clothing", "Children", "Decor", "Donations", "Drinks", "Education", "Entertainment", "Family", "Fitness", "Food", "Games", "Gas", "General", "Gifts", "Groceries", "Haircuts", "Health", "Hobbies", "Household", "Laundry", "Leisure", "Loan", "Motorcycle", "Music", "Other", "Payment", "Personal", "Pets", "Restaurant", "Shopping", "Significant Other", "Smoking", "Social", "Technology", "Tools", "Transportation", "Travel", "Treats", "Vacations", "Work"];
    var incomeFields = ["Uncategorized", "Bonus", "Donation", "Extra Income", "Gift", "Investment", "Other", "Payday", "Payment", "Sale"]
    var pickerFields: [String]? = []
    
    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerFields!.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerFields?[row]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(type == "expense"){
            pickerFields = expenseFields
        }
        else{
            pickerFields = incomeFields
        }
        
        
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
        if recurringSwitch.isOn {recurring = true}
        else {recurring = false}
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func datePickerChanged(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
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
        
        recurringSwitch.isOn = recurring
        noteField.text! = note
        amountField.text! = amount
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateObj = dateFormatter.date(from: date)
        datePicker.date = dateObj!
        if type == "expense" {
            categoryPicker.selectRow(expenseFields.index(where: {$0 == category})!, inComponent: 0, animated: true)
        }
        if type == "income" {
            categoryPicker.selectRow(incomeFields.index(where: {$0 == category})!, inComponent: 0, animated: true)
        }
        categoryPicker.reloadAllComponents()
        
        //let day = Date()
        //let formatter = DateFormatter()
        //formatter.dateFormat = "yyyy-MM-dd"
        //let today = formatter.string(from: day)
        //date = today
        
    }
    
    func returnToRecords() {
        //amount = String(describing: Double(amountField.text!))
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        var amt = 0.0
        amt = (amountField.text! as NSString).doubleValue
        amount = formatter.string(from: NSNumber(value: amt))!
        if (amount != "") {
            delegate?.userDidChangeDateInformation(info: date)
            note = noteField.text!
            delegate?.userDidChangeNoteInformation(info: note)
            delegate?.userDidChangeAmountInformation(info: amount)
            category = (pickerFields?[categoryPicker.selectedRow(inComponent: 0)])!
            delegate?.userDidChangeCategoryInformation(info: category)
            delegate?.userDidChangeRecurringInformation(info: recurring)
            if type != "expense" {
                delegate?.userDidChangeTypeInformation(info: "income")
            }
            else {
                delegate?.userDidChangeTypeInformation(info: "expense")
            }
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
