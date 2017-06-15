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
    var key: String?

    
    init (snapshot: DataSnapshot) {
        ref = snapshot.ref
        var data = snapshot.value as! Dictionary<String, Any>
        date = data["date"]! as? String
        type = data["type"]! as? String
        amount = data["amount"]! as? String
        note = data["note"]! as? String
        category = data["category"]! as? String
        recurring = data["recurring"]! as? Bool
        key = data["key"]! as? String
    }
}

class RecordsViewController: UITableViewController, ExpenseDataEnteredDelegate, IncomeDataEnteredDelegate, EditDataEnteredDelegate {
    
    var records = 0 {
        didSet{
            if records == 6 {
                records = 0
                let dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                key = dbref.key
                let transDict = [
                    "date": date ?? "",
                    "amount": amount ?? "",
                    "note": note ?? "",
                    "category": category ?? "",
                    "recurring": recurring ?? false,
                    "type": type ?? "",
                    "key": key ?? ""
                ] as [String : Any]
                createNewTransaction(transaction: transDict, transactionID: dbref)
            }
        }
    }
    
    func createNewTransaction(transaction: Dictionary<String, Any>, transactionID: DatabaseReference) {
        transactionID.setValue(transaction)
    }
    
    func replaceTransaction(id: String) {
        let post = ["date": changeDate ?? "",
                    "amount": changeAmount ?? "",
                    "note": changeNote ?? "",
                    "category": changeCategory ?? "",
                    "recurring": changeRecurring ?? false,
                    "type": changeType ?? "",
                    "key": id] as [String : Any]
        let childUpdates = ["/users/\(self.user.uid)/transactions/\(id)/": post]
        ref.updateChildValues(childUpdates)
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
    var key: String? = ""
    
    var changeRecords = 0 {
        didSet{
            if changeRecords == 6 {
                changeRecords = 0
                replaceTransaction(id: changeKey!)
            }
        }
    }
    var changeDate: String? {
        didSet{
            changeRecords += 1
        }
    }
    var changeAmount: String? {
        didSet{
            changeRecords += 1
        }
    }
    var changeNote: String? {
        didSet{
            changeRecords += 1
        }
    }
    var changeCategory: String? {
        didSet{
            changeRecords += 1
        }
    }
    var changeRecurring: Bool? {
        didSet{
            changeRecords += 1
        }
    }
    var changeType: String? {
        didSet{
            changeRecords += 1
        }
    }
    var changeKey: String? = ""
    
    
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

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let ip = tableView.indexPathForSelectedRow
        //let currentCell = tableView.cellForRow(at: ip!)!
        let cellAmount = transactions[indexPath.row].amount
        let cellDate = transactions[indexPath.row].date
        let cellCategory = transactions[indexPath.row].category
        var cellRecurring: String?
        if transactions[indexPath.row].recurring! {
            cellRecurring = "true"
        }
        else {
            cellRecurring = "false"
        }
        let cellNote = transactions[indexPath.row].note
        let cellType = transactions[indexPath.row].type

        let theSender = [cellAmount!, cellCategory!, cellDate!, cellNote!, cellRecurring!, cellType!]
        performSegue(withIdentifier: "toDetail", sender: theSender)
        changeKey = transactions[indexPath.row].key
    }
    
    func changeInfo() {
        
    }
    
    func didTapAddIncome() {
        performSegue(withIdentifier: "addIncomeFromRecords", sender: nil)
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
    
    func userDidChangeAmountInformation(info: String){
        changeAmount = info
    }
    func userDidChangeCategoryInformation(info: String){
        changeCategory = info
    }
    func userDidChangeDateInformation(info: String){
        changeDate = info
    }
    func userDidChangeNoteInformation(info: String){
        changeNote = info
    }
    func userDidChangeRecurringInformation(info: Bool){
        changeRecurring = info
    }
    func userDidChangeTypeInformation(info: String){
        changeType = info
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpenseFromRecords" {
            let expenseVC = segue.destination as! AddExpenseViewController
            expenseVC.delegate = self
        }
        if segue.identifier == "addIncomeFromRecords" {
            let incomeVC = segue.destination as! AddIncomeViewController
            incomeVC.delegate = self
        }
        if segue.identifier == "toDetail" {
            let changeVC = segue.destination as! EditTransactionViewController
            changeVC.delegate = self
            
            let senderArray = sender as! [String]
            
            changeVC.amount = senderArray[0] as String
            changeVC.category = senderArray[1] as String
            changeVC.date = senderArray[2] as String
            changeVC.note = senderArray[3] as String
            if senderArray[4] == "true" {
                changeVC.recurring = true
            }
            else {
                changeVC.recurring = false
            }
            changeVC.type = senderArray[5] as String
        }
    }
    
    func didTapAddExpense() {
        performSegue(withIdentifier: "addExpenseFromRecords", sender: nil)
    }
    
    func startObservingDatabase() {
        databaseHandle = ref.child("users/\(self.user.uid)/transactions").observe(.value, with: { (snapshot) in
            var newTransactions = [Transaction]()
            var transaction: Transaction?
            for itemSnapShot in snapshot.children {
                transaction = Transaction(snapshot: itemSnapShot as! DataSnapshot)
                newTransactions.append(transaction!)
            }
            self.transactions = newTransactions
            self.tableView.reloadData()
            
        })
    }
}
