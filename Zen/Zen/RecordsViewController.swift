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
    
    var dateSections: [String]? = []
    var dateData: [[String]]? = []
    
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
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (dateSections?.count)!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.minimumIntegerDigits = 1
        var total = 0.0
        for amountString in (dateData?[section])! {
            total += Double(amountString) ?? 0.0
        }
        return (dateSections?[section])!+": "+currency+formatter.string(from: NSNumber(value: total))!
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateData![section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.transactions.sort(by: {
            df.date(from: $0.date!)! > df.date(from: $1.date!)!
        })
        
        //indexPath.section = dateSections?.index(of: (dateSections?.first(where: {$0 == (transactions[indexPath.row]?.date)!}))!)
        
        var row = 0
        let ipsec = indexPath.section
        var currsec = 0
        let iprow = indexPath.row
        
        while currsec < ipsec {
            row += tableView.numberOfRows(inSection: currsec)
            currsec += 1
        }
        row += iprow
        
        let transaction = self.transactions[row]
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
        var row = 0
        let ipsec = indexPath.section
        var currsec = 0
        let iprow = indexPath.row
        
        while currsec < ipsec {
            row += tableView.numberOfRows(inSection: currsec)
            currsec += 1
        }
        row += iprow
        if editingStyle == .delete {
            let transaction = transactions[row]
            transaction.ref?.removeValue()
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var row = 0
        let ipsec = indexPath.section
        var currsec = 0
        let iprow = indexPath.row
        
        while currsec < ipsec {
            row += tableView.numberOfRows(inSection: currsec)
            currsec += 1
        }
        row += iprow
        //let ip = tableView.indexPathForSelectedRow
        //let currentCell = tableView.cellForRow(at: ip!)!
        let cellAmount = transactions[row].amount
        let cellDate = transactions[row].date
        let cellCategory = transactions[row].category
        var cellRecurring: String?
        if transactions[row].recurring! {
            cellRecurring = "true"
        }
        else {
            cellRecurring = "false"
        }
        let cellNote = transactions[row].note
        let cellType = transactions[row].type

        let theSender = [cellAmount!, cellCategory!, cellDate!, cellNote!, cellRecurring!, cellType!]
        performSegue(withIdentifier: "toDetail", sender: theSender)
        changeKey = transactions[row].key
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
        databaseHandle = ref.child("users/\(self.user.uid)/transactions").queryOrdered(byChild: "date").observe(.value, with: { (snapshot) in
            var newTransactions = [Transaction]()
            var newDateSections = [String]()
            var newDateData = [[String]]()
            var transaction: Transaction?
            for itemSnapShot in snapshot.children {
                transaction = Transaction(snapshot: itemSnapShot as! DataSnapshot)
                
                if !newDateSections.contains(where: {$0 == (transaction?.date)!}) {
                    newDateSections.append((transaction?.date)!)
                    if (transaction?.type)! == "expense" {
                        newDateData.append(["-" + (transaction?.amount)!])
                    }
                    else if (transaction?.type)! == "income" {
                        newDateData.append([(transaction?.amount)!])
                    }
                }
                else {
                    if (transaction?.type)! == "expense" {
                        newDateData[(newDateSections.index(of: (newDateSections.first(where: {$0 == (transaction?.date)!}))!))!].append("-" + (transaction?.amount)!)
                    }
                    else if (transaction?.type)! == "income" {
                        newDateData[(newDateSections.index(of: (newDateSections.first(where: {$0 == (transaction?.date)!}))!))!].append((transaction?.amount)!)
                    }
                }
                
                newTransactions.append(transaction!)
            }
            print(newDateSections)
            print(newDateData)
            
            //sort data
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            
            
            let count = newDateSections.count
            
            // Create the array of tuples and sort according to the
            // first tuple value (i.e. the first array)
            let sortedTuples =
                (0..<count).map { (newDateSections[$0], newDateData[$0]) }.sorted { df.date(from: $0.0)! > df.date(from: $1.0)!}
            
            // Map over the sorted tuples array to separate out the
            // original (now sorted) arrays.
            newDateSections = sortedTuples.map { $0.0 }
            newDateData = sortedTuples.map { $0.1 }
            
            
            print(newDateSections)
            print(newDateData)
            self.dateSections = newDateSections
            self.dateData = newDateData
            self.transactions = newTransactions
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
            
        })
    }
    
    deinit {
        ref.child("users/\(self.user.uid)/transactions").removeObserver(withHandle: databaseHandle)
    }
}
