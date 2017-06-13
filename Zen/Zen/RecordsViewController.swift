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
    //var note: String?

    
    init (snapshot: DataSnapshot) {
        ref = snapshot.ref
        let data = snapshot.value as! Dictionary<String, String>
        if data["date"] != nil {
           date = data["date"]! as String
        }
        else if data["type"] != nil {
            type = data["type"]! as String
        }
        else if data["amount"] != nil {
            amount = data["amount"]! as String
        }
        //else if data["note"] != nil {
        //    note = data["note"]! as String
        //}
    }
    
}

class RecordsViewController: UITableViewController {
    
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
        cell.textLabel?.text = transaction.amount
        if transaction.type == "expense"{
            cell.backgroundColor = UIColor.red
            cell.textLabel?.textColor = UIColor.white
        }
        if transaction.type == "income"{
            cell.backgroundColor = UIColor.blue
            cell.textLabel?.textColor = UIColor.white
        }
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
    
    func didTapAddExpense() {
        
        let prompt = UIAlertController(title: "Add Expense", message: "Please enter amount.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            //let noteInput = prompt.textFields![1].text
            if (userInput!.isEmpty) {
                return
            }
            self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("amount").setValue(userInput)
            self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("type").setValue("expense")
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let today = formatter.string(from: date)
            self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("date").setValue(today)
            //self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId().child("note").setValue(noteInput)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        prompt.addAction(cancelAction)
        present(prompt, animated: true, completion: nil);
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
                    transaction?.date = Transaction(snapshot: itemSnapShot as! DataSnapshot).date
                    counter += 1
                    break
                //case 3:
                //    transaction?.note = Transaction(snapshot: itemSnapShot as! DataSnapshot).note
                //    newTransactions.append(transaction!)
                //    counter = 0
                default:
                    break
                }
                
            }
            self.transactions = newTransactions
            self.tableView.reloadData()
            
        })
    }
    
    deinit {
        ref.child("users/\(self.user.uid)/transactions").removeObserver(withHandle: databaseHandle)
    }
}
