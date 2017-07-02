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

var totalAssets: Float = 0.00

class BudgetViewController: UIViewController, IncomeDataEnteredDelegate, ExpenseDataEnteredDelegate {
    var user: User!
    var ref: DatabaseReference!

    @IBOutlet weak var emailDisplay: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var savingsLabel: UILabel!
    @IBOutlet weak var accountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        emailDisplay.text = "\(getEmail())"
        
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        
        ref.child("users/\(self.user.uid)/account").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? Float ?? 0.00
            totalAssets = value
        })

        var budgetNumber = 0.00
        var savingsNumber = 0.00
        var totalNumber = totalAssets
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        ref.child("users").child(self.user.uid).child("transactions").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for itemSnapShot in snapshot.children {
                let transaction = Transaction(snapshot: itemSnapShot as! DataSnapshot)
                if transaction.type == "expense" {
                    budgetNumber -= formatter.number(from: transaction.amount!) as! Double
                    totalNumber -= formatter.number(from: transaction.amount!) as! Float
                }
                if transaction.type == "income" {
                    budgetNumber += formatter.number(from: transaction.amount!) as! Double
                    totalNumber += formatter.number(from: transaction.amount!) as! Float
                }
                if transaction.type == "savings" {
                    savingsNumber += formatter.number(from: transaction.amount!) as! Double
                    totalNumber += formatter.number(from: transaction.amount!) as! Float
                }
            }
            if budgetNumber >= 0 {
                self.budgetLabel.textColor = UIColor.blue
            }
            else {
                self.budgetLabel.textColor = UIColor.red
            }
            self.budgetLabel.text = currency + formatter.string(from: NSNumber(value: budgetNumber))!
            self.savingsLabel.text = currency + formatter.string(from: NSNumber(value: savingsNumber))!
            self.accountLabel.text = currency + formatter.string(from: NSNumber(value: totalNumber))!
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var budgetNumber = 0.00
        var savingsNumber = 0.00
        var totalNumber = totalAssets
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        ref.child("users").child(self.user.uid).child("transactions").observeSingleEvent(of: .value, with: { (snapshot) in
            
            for itemSnapShot in snapshot.children {
                let transaction = Transaction(snapshot: itemSnapShot as! DataSnapshot)
                if transaction.type == "expense" {
                    budgetNumber -= formatter.number(from: transaction.amount!) as! Double
                    totalNumber -= formatter.number(from: transaction.amount!) as! Float
                }
                if transaction.type == "income" {
                    budgetNumber += formatter.number(from: transaction.amount!) as! Double
                    totalNumber += formatter.number(from: transaction.amount!) as! Float
                }
                if transaction.type == "savings" {
                    savingsNumber += formatter.number(from: transaction.amount!) as! Double
                    totalNumber += formatter.number(from: transaction.amount!) as! Float
                }
            }
            if budgetNumber >= 0 {
                self.budgetLabel.textColor = UIColor.blue
            }
            else {
                self.budgetLabel.textColor = UIColor.red
            }
            self.budgetLabel.text = currency + formatter.string(from: NSNumber(value: budgetNumber))!
            self.savingsLabel.text = currency + formatter.string(from: NSNumber(value: savingsNumber))!
            self.accountLabel.text = currency + formatter.string(from: NSNumber(value: totalNumber))!
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getEmail() -> String {
        return (Auth.auth().currentUser?.email)!
    }
    
    var records = 0 {
        didSet{
            if records == 7 {
                records = 0
                var dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                var dbref2 = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                key = dbref.key
                var savKey = dbref2.key
                var transDict: [String: Any] = [
                    "date": date ?? "",
                    "amount": amount ?? "",
                    "note": note ?? "",
                    "category": category ?? "",
                    "recurring": recurring ?? false,
                    "type": type ?? "",
                    "recurType": recurType ?? "",
                    "key": key ?? ""
                ]
                var savingsDict: [String: Any] = [
                    "date": savingsDate ?? "",
                    "amount": savingsAmount ?? "",
                    "note": savingsNote ?? "",
                    "category": savingsCategory ?? "",
                    "recurring": savingsRecurring ?? false,
                    "type": savingsType ?? "",
                    "recurType": savingsRecurType ?? "",
                    "key": savKey
                ]
                //if its a recurring transaction in the past, add extra transactions between then and now
                if transDict["recurring"] as! Bool == true {
                    var d = transDict["date"] as! String
                    let todayDate = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: todayDate)
                    let tomorrow = formatter.string(from: tomorrowDate!)
                    switch recurType {
                    case "day"?:
                        while d < tomorrow {
                            transDict["date"] = d
                            savingsDict["date"] = d
                            transDict["key"] = key
                            savingsDict["key"] = savKey
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            if transDict["type"] as! String == "income" {
                                createNewTransaction(transaction: savingsDict, transactionID: dbref2)
                            }
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: newDate!) // += 1 day
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            dbref2 = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                            savKey = dbref2.key
                        }
                        break
                    case "week"?:
                        while d < tomorrow {
                            transDict["date"] = d
                            savingsDict["date"] = d
                            transDict["key"] = key
                            savingsDict["key"] = savKey
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            if transDict["type"] as! String == "income" {
                                createNewTransaction(transaction: savingsDict, transactionID: dbref2)
                            }
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .day, value: 7, to: newDate!) // += 1 wk
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            dbref2 = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                            savKey = dbref2.key
                        }
                        break
                    case "biweek"?:
                        while d < tomorrow {
                            transDict["date"] = d
                            savingsDict["date"] = d
                            transDict["key"] = key
                            savingsDict["key"] = savKey
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            if transDict["type"] as! String == "income" {
                                createNewTransaction(transaction: savingsDict, transactionID: dbref2)
                            }
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .day, value: 14, to: newDate!) // += 14 day
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            dbref2 = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                            savKey = dbref2.key
                        }
                        break
                    case "month"?:
                        while d < tomorrow {
                            transDict["date"] = d
                            savingsDict["date"] = d
                            transDict["key"] = key
                            savingsDict["key"] = savKey
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            if transDict["type"] as! String == "income" {
                                createNewTransaction(transaction: savingsDict, transactionID: dbref2)
                            }
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: newDate!) // += 1 mo
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            dbref2 = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                            savKey = dbref2.key
                        }
                        break
                    case "year"?:
                        while d < tomorrow {
                            transDict["date"] = d
                            savingsDict["date"] = d
                            transDict["key"] = key
                            savingsDict["key"] = savKey
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            if transDict["type"] as! String == "income" {
                                createNewTransaction(transaction: savingsDict, transactionID: dbref2)
                            }
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .year, value: 1, to: newDate!) // += 1 yr
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            dbref2 = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                            savKey = dbref2.key
                        }
                        break
                    default:
                        break
                    }
                }
                    //else just create one transaction
                else {
                    createNewTransaction(transaction: transDict, transactionID: dbref)
                    if transDict["type"] as! String == "income" {
                        createNewTransaction(transaction: savingsDict, transactionID: dbref2)
                    }
                }
            }
        }
    }

    var date: String?{
        didSet{
            records += 1
        }
    }
    var amount: String? {
        didSet{
            records += 1
        }
    }
    var note: String? {
        didSet{
            records += 1
        }
    }
    var category: String? {
        didSet{
            records += 1
        }
    }
    var recurring: Bool? {
        didSet{
            records += 1
        }
    }
    var type: String? {
        didSet{
            records += 1
        }
    }
    var recurType: String? {
        didSet{
            records += 1
        }
    }
    var key: String? = ""
    var savingsDate: String?
    var savingsAmount: String?
    var savingsNote: String?
    var savingsCategory: String?
    var savingsRecurring: Bool?
    var savingsType: String?
    var savingsRecurType: String?
    var savingsKey: String?
    func createNewTransaction(transaction: Dictionary<String, Any>, transactionID: DatabaseReference) {
        transactionID.setValue(transaction)
    }

    
    func userDidEnterNoteInformation(info: String) {
        note = info
    }
    func userDidEnterDateInformation(info: String) {
        date = info
    }
    func userDidEnterAmountInformation(info: String) {
        amount = info
    }
    func userDidEnterCategoryInformation(info: String) {
        category = info
    }
    func userDidEnterRecurringInformation(info: Bool) {
        recurring = info
    }
    func userDidEnterTypeInformation(info: String) {
        type = info
    }
    func userDidEnterRecurTypeInformation(info: String) {
        recurType = info
    }
    
    func savingsNoteInformation(info: String) {
        savingsNote = info
    }
    func savingsDateInformation(info: String) {
        savingsDate = info
    }
    func savingsAmountInformation(info: String) {
        savingsAmount = info
    }
    func savingsCategoryInformation(info: String) {
        savingsCategory = info
    }
    func savingsRecurringInformation(info: Bool) {
        savingsRecurring = info
    }
    func savingsTypeInformation(info: String) {
        savingsType = info
    }
    func savingsRecurTypeInformation(info: String) {
        savingsRecurType = info
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpenseFromBudget" {
            let expenseVC = segue.destination as! AddExpenseViewController
            expenseVC.delegate = self
        }
        if segue.identifier == "addIncomeFromBudget" {
            let incomeVC = segue.destination as! AddIncomeViewController
            incomeVC.delegate = self
        }
    }

    
}
