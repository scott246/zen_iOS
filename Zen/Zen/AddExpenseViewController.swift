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
    func userDidEnterTypeInformation(info:String)
    func userDidEnterRecurTypeInformation(info:String)
}

class AddExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    var type: String!
    var amount: String!
    var category: String = "Uncategorized"
    var date: String!
    var note: String!
    var recurring: Bool! = false
    var recurType: String!

    func numberOfComponents(in: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 1) {
            return pickerFields.count
        } else {
            return recurrenceFields.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return pickerFields[row]
        }
        else {
            return recurrenceFields[row]
        }
    }
    weak var delegate: ExpenseDataEnteredDelegate? = nil
    
    var pickerFields = ["Uncategorized", "Automotive", "Bills", "Coffee", "Clothing", "Children", "Decor", "Donations", "Drinks", "Education", "Entertainment", "Family", "Fitness", "Food", "Games", "Gas", "General", "Gifts", "Groceries", "Haircuts", "Health", "Hobbies", "Household", "Laundry", "Leisure", "Loan", "Motorcycle", "Music", "Other", "Payment", "Personal", "Pets", "Restaurant", "Shopping", "Significant Other", "Smoking", "Social", "Technology", "Tools", "Transportation", "Travel", "Treats", "Vacations", "Work"]
    var recurrenceFields = ["day", "week", "biweek", "month", "year"]
    
    
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
        if recurringSwitch.isOn {
            recurring = true
            segmenter.setEnabled(true, forSegmentAt: 2)
        }
        else {
            recurring = false
            segmenter.setEnabled(false, forSegmentAt: 2)
        }
    }
    @IBOutlet weak var recurCyclePicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func datePickerChanged(_ sender: Any) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        date = formatter.string(from: datePicker.date)
    }
    @IBOutlet weak var startingLabel: UILabel!
    @IBOutlet weak var recurEveryLabel: UILabel!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBAction func segmenterChanged(_ sender: Any) {
        if segmenter.selectedSegmentIndex == 0 {
            categoryPicker.isHidden = true
            datePicker.isHidden = false
            noteField.isHidden = false
            amountField.isHidden = false
            recurringSwitch.isHidden = false
            recurringExpenseLabel.isHidden = false
            recurCyclePicker.isHidden = true
            recurEveryLabel.isHidden = true
            startingLabel.isHidden = true
        }
        else if segmenter.selectedSegmentIndex == 1 {
            self.amountField.resignFirstResponder()
            self.noteField.resignFirstResponder()
            categoryPicker.isHidden = false
            datePicker.isHidden = true
            noteField.isHidden = true
            amountField.isHidden = true
            recurringSwitch.isHidden = true
            recurringExpenseLabel.isHidden = true
            recurCyclePicker.isHidden = true
            recurEveryLabel.isHidden = true
            startingLabel.isHidden = true
        }
        else if segmenter.selectedSegmentIndex == 2 {
            self.amountField.resignFirstResponder()
            self.noteField.resignFirstResponder()
            categoryPicker.isHidden = true
            datePicker.isHidden = false
            noteField.isHidden = true
            amountField.isHidden = true
            recurringSwitch.isHidden = true
            recurringExpenseLabel.isHidden = true
            recurCyclePicker.isHidden = false
            recurEveryLabel.isHidden = false
            startingLabel.isHidden = false
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
        
        self.recurCyclePicker.dataSource = self
        self.recurCyclePicker.delegate = self
        
        categoryPicker.isHidden = true
        recurCyclePicker.isHidden = true
        recurEveryLabel.isHidden = true
        startingLabel.isHidden = true
        
        recurringSwitch.isOn = recurring
        if recurring {
            segmenter.setEnabled(true, forSegmentAt: 2)
        }
        else {
            segmenter.setEnabled(false, forSegmentAt: 2)
        }
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(returnToRecords)), animated: true)
        
        let day = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: day)
        date = today
        
        recurType = "day"

    }
    
    func returnToRecords() {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        var amt = 0.0
        amt = (amountField.text! as NSString).doubleValue
        amount = formatter.string(from: NSNumber(value: amt))!
        delegate?.userDidEnterDateInformation(info: date)
        note = noteField.text!
        delegate?.userDidEnterNoteInformation(info: note)
        delegate?.userDidEnterAmountInformation(info: amount)
        category = pickerFields[categoryPicker.selectedRow(inComponent: 0)]
        delegate?.userDidEnterCategoryInformation(info: category)
        delegate?.userDidEnterRecurringInformation(info: recurring)
        delegate?.userDidEnterTypeInformation(info: "expense")
        recurType = recurrenceFields[recurCyclePicker.selectedRow(inComponent: 0)]
        delegate?.userDidEnterRecurTypeInformation(info: recurType)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
