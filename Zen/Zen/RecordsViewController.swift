//
//  RecordsViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/13/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class Transaction {
    
    var ref: DatabaseReference?
    var date: String?
    var type: String?
    var amount: String?
    var note: String?
    var category: String?
    var recurring: Bool?

    
    init (snapshot: DataSnapshot) {
        ref = snapshot.ref
        var data = snapshot.value as! Dictionary<String, Any>
        if data["date"] != nil {
            date = data["date"]! as? String
        }
        else if data["type"] != nil {
            type = data["type"]! as? String
        }
        else if data["amount"] != nil {
            amount = data["amount"]! as? String
        }
        else if data["note"] != nil {
            note = data["note"]! as? String
        }
        else if data["category"] != nil {
            category = data["category"]! as? String
        }
        else {
            recurring = data["recurring"]! as? Bool
        }
    }
}

class RecordsViewController: UITableViewController, ExpenseDataEnteredDelegate {
    
    var records = 0 {
        didSet{
            if records == 5 {
                records = 0
                self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("date").setValue(date)
                self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("type").setValue("expense")
                self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("amount").setValue(amount)
                self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("note").setValue(note)
                self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("category").setValue(category)
                self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("recurring").setValue(recurring)
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
    
    var user: User!
    var transactions = [Transaction]()
    var ref: DatabaseReference!
    private var databaseHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setLeftBarButtonItems([UIBarButtonItem(title: "Add Income", style: .plain, target: self, action: #selector(didTapAddIncome))], animated: true)
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(title: "Add Expense", style: .plain, target: self, action: #selector(didTapAddExpense))], animated: true)
        
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        startObservingDatabase()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        let transaction = transactions[indexPath.row]
        var sign: String = ""
        if transaction.type == "expense"{
            sign = "-"
            cell.backgroundColor = UIColor.red
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
        }
        if transaction.type == "income"{
            sign = "+"
            cell.backgroundColor = UIColor.blue
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
        }
        cell.detailTextLabel?.text = transaction.date! + " (" + sign + currency + transaction.amount! + ")"
        cell.textLabel?.text = transaction.category! + " (" + transaction.note! + ")"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let transaction = transactions[indexPath.row]
            transaction.ref?.removeValue()
        }
    }
    
    func didTapAddIncome() {
        let prompt = UIAlertController(title: "Add Income", message: "Please enter amount.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("amount").setValue(userInput)
            self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("type").setValue("income")
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let today = formatter.string(from: date)
            self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("date").setValue(today)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        prompt.addAction(cancelAction)
        present(prompt, animated: true, completion: nil);
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpenseFromRecords" {
            let expenseVC = segue.destination as! AddExpenseViewController
            expenseVC.delegate = self
        }
        if segue.identifier == "addIncomeFromRecords" {
            //let incomeVC = segue.destination as! AddIncomeViewController
            //incomeVC.delegate = self
        }
    }
    
    func didTapAddExpense() {
        performSegue(withIdentifier: "addExpenseFromRecords", sender: nil)
    }
    
    func startObservingDatabase() {
        databaseHandle = ref.child("users/\(self.user.uid)/transactions").observe(.value, with: { (snapshot) in
            var newTransactions = [Transaction]()
            var counter = 0
            var transaction: Transaction?
            for itemSnapShot in snapshot.children {
                switch counter {
                case 0:
                    transaction = Transaction(snapshot: itemSnapShot as! DataSnapshot)
                    counter += 1
                    break
                case 1:
                    transaction?.type = Transaction(snapshot: itemSnapShot as! DataSnapshot).type
                    counter += 1
                    break
                case 2:
                    transaction?.amount = Transaction(snapshot: itemSnapShot as! DataSnapshot).amount
                    counter += 1
                    break
                case 3:
                    transaction?.note = Transaction(snapshot: itemSnapShot as! DataSnapshot).note
                    counter += 1
                    break
                case 4:
                    transaction?.category = Transaction(snapshot: itemSnapShot as! DataSnapshot).category
                    counter += 1
                    break
                case 5:
                    transaction?.recurring = Transaction(snapshot: itemSnapShot as! DataSnapshot).recurring
                    newTransactions.append(transaction!)
                    counter = 0
                default:
                    break
                }
                
            }
            self.transactions = newTransactions
            self.tableView.reloadData()
            
        })
    }
}
