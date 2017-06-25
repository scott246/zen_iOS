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

//transaction class
class Transaction {
    
    var ref: DatabaseReference?
    var date: String?
    var type: String?
    var amount: String?
    var note: String?
    var category: String?
    var recurring: Bool?
    var recurType: String?
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
        recurType = data["recurType"]! as? String
        key = data["key"]! as? String
    }
}

class RecordsViewController: UITableViewController, ExpenseDataEnteredDelegate, IncomeDataEnteredDelegate, EditDataEnteredDelegate {
    
    //data for each date is stored in sections and data such that the each data is mapped to a section
    var dateSections: [String]? = []
    var dateData: [[Transaction]]? = []

    //when the date, amount, note, category, recurring, type, and key vars are filled, create a new transaction
    var records = 0 {
        didSet{
            if records == 7 {
                records = 0
                var dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                key = dbref.key
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
                            transDict["key"] = key
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: newDate!) // += 1 day
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                        }
                        break
                    case "week"?:
                        while d < tomorrow {
                            transDict["date"] = d
                            transDict["key"] = key
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .day, value: 7, to: newDate!) // += 1 day
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                        }
                        break
                    case "biweek"?:
                        while d < tomorrow {
                            transDict["date"] = d
                            transDict["key"] = key
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .day, value: 14, to: newDate!) // += 1 day
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                        }
                        break
                    case "month"?:
                        while d < tomorrow {
                            transDict["date"] = d
                            transDict["key"] = key
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .month, value: 1, to: newDate!) // += 1 day
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                        }
                        break
                    case "year"?:
                        while d < tomorrow {
                            transDict["date"] = d
                            transDict["key"] = key
                            createNewTransaction(transaction: transDict, transactionID: dbref)
                            let newDate = formatter.date(from: d)
                            let nextDate = Calendar.current.date(byAdding: .year, value: 1, to: newDate!) // += 1 day
                            d = formatter.string(from: nextDate!)
                            dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                            key = dbref.key
                        }
                        break
                    default:
                        break
                    }
                }
                //else just create one transaction
                else {
                    createNewTransaction(transaction: transDict, transactionID: dbref)
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
    func createNewTransaction(transaction: Dictionary<String, Any>, transactionID: DatabaseReference) {
        transactionID.setValue(transaction)
    }
    
    //when the date, amount, note, category, recurring, type, and key vars are changed, replace the transaction at the given key
    var changeRecords = 0 {
        didSet{
            if changeRecords == 7 {
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
    var changeRecurType: String? {
        didSet{
            changeRecords += 1
        }
    }
    var changeKey: String? = ""
    func replaceTransaction(id: String) {
        let post: [String:Any] = ["date": changeDate ?? "",
                    "amount": changeAmount ?? "",
                    "note": changeNote ?? "",
                    "category": changeCategory ?? "",
                    "recurring": changeRecurring ?? false,
                    "type": changeType ?? "",
                    "recurType": changeRecurType ?? "",
                    "key": id] as [String : Any]
        let childUpdates = ["/users/\(self.user.uid)/transactions/\(id)/": post]
        ref.updateChildValues(childUpdates)
    }
    
    //array of transactions from the database
    var transactions = [Transaction]()

    //variables used to retrieve/send data from/to the database
    var user: User!
    var ref: DatabaseReference!
    private var databaseHandle: DatabaseHandle!

    
    //viewDidLoad() function: set database variables, set bar button items, start observing database
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setLeftBarButtonItems([UIBarButtonItem(title: "Add Income", style: .plain, target: self, action: #selector(didTapAddIncome))], animated: true)
        self.navigationItem.setRightBarButtonItems(
            [UIBarButtonItem(title: "Add Expense", style: .plain, target: self, action: #selector(didTapAddExpense)),
             UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(didTapSearch))], animated: true)
        
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        startObservingDatabase()
    }
    
    //bar button item functions: segue to respective pages
    func didTapAddIncome() {
        performSegue(withIdentifier: "addIncomeFromRecords", sender: nil)
    }
    func didTapAddExpense() {
        performSegue(withIdentifier: "addExpenseFromRecords", sender: nil)
    }
    func didTapSearch() {
        performSegue(withIdentifier: "toSearch", sender: self)
    }
    
    // MARK: table overrides
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
            if amountString.type == "expense"{
                total -= Double(amountString.amount!) ?? 0.0
            }
            else {
                total += Double(amountString.amount!) ?? 0.0
            }
            
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
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.red
        }
        if transaction.type == "income"{
            sign = "+"
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.blue
        }
        if transaction.recurring! {
            cell.detailTextLabel?.text = "(recurring every \(transaction.recurType!)) " + sign + currency + transaction.amount!
        }
        else {
            cell.detailTextLabel?.text = sign + currency + transaction.amount!
        }
        cell.textLabel?.text = transaction.note! + " (" + transaction.category! + ")"
        
        return cell
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dateSections
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
        let cellRecurType = transactions[row].recurType

        let theSender = [cellAmount!, cellCategory!, cellDate!, cellNote!, cellRecurring!, cellRecurType!, cellType!]
        performSegue(withIdentifier: "toDetail", sender: theSender)
        changeKey = transactions[row].key
    }
    
    //functions used to pass information from add/edit expense/income pages
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
    func userDidChangeRecurTypeInformation(info: String){
        changeRecurType = info
    }
    
    //function used to prepare segue for sending and receiving information to the pages
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
                changeVC.recurType = senderArray[5] as String
            }
            else {
                changeVC.recurring = false
                changeVC.recurType = senderArray[5] as String
            }
            changeVC.type = senderArray[6] as String
        }
        if segue.identifier == "toSearch" {
            let searchVC = segue.destination as! RecordsSearchViewController
            searchVC.delegate = self
            searchVC.dateData = dateData!
            searchVC.dateSections = dateSections!
            searchVC.transactions = transactions
        }
    }
    
    //function that retrieves information from the database any time there is a change
    func startObservingDatabase() {
        var databaseHandleInProgress = false
        var recurringTransactions = [Transaction]() {
            didSet {
                DispatchQueue.main.async{
                    while databaseHandleInProgress == true {
                        continue
                    }
                    self.doRecurringTransactions(recurringTransactions: recurringTransactions)
                }
            }
        }
        
        databaseHandle = ref.child("users/\(self.user.uid)/transactions").queryOrdered(byChild: "date").observe(.value, with: { (snapshot) in
            databaseHandleInProgress = true
            var newTransactions = [Transaction]()
            var newDateSections = [String]()
            var newDateData = [[Transaction]]()
            var transaction: Transaction?
            for itemSnapShot in snapshot.children {
                transaction = Transaction(snapshot: itemSnapShot as! DataSnapshot)
                //if newDateSections already contains that date, append to the section data, otherwise make a new section entry and data entry
                if !newDateSections.contains(where: {$0 == (transaction?.date)!}) {
                    newDateSections.append((transaction?.date)!)
                    if (transaction?.type)! == "expense" {
                        //transaction?.amount = "-" + (transaction?.amount)!
                        newDateData.append([transaction!])
                    }
                    else if (transaction?.type)! == "income" {
                        newDateData.append([transaction!])
                    }
                }
                else {
                    if (transaction?.type)! == "expense" {
                        //transaction?.amount = "-" + (transaction?.amount)!
                        newDateData[(newDateSections.index(of: (newDateSections.first(where: {$0 == (transaction?.date)!}))!))!].append(transaction!)
                    }
                    else if (transaction?.type)! == "income" {
                        newDateData[(newDateSections.index(of: (newDateSections.first(where: {$0 == (transaction?.date)!}))!))!].append(transaction!)
                    }
                }
                //if it's a recurring entry, make it recur
                if (transaction?.recurring)! {
                    if !recurringTransactions.contains(where: {
                        $0.amount == (transaction?.amount)! &&
                        $0.category == (transaction?.category)! &&
                        $0.note == (transaction?.note)! &&
                        $0.recurring == (transaction?.recurring)! &&
                        $0.recurType == (transaction?.recurType)! &&
                        $0.type == (transaction?.type)!
                        }){
                        recurringTransactions.append(transaction!)
                    }
                }
                newTransactions.append(transaction!)
            }
            //sort data
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let count = newDateSections.count
            let sortedTuples =
                (0..<count).map { (newDateSections[$0], newDateData[$0]) }.sorted { df.date(from: $0.0)! > df.date(from: $1.0)!}
            newDateSections = sortedTuples.map { $0.0 }
            newDateData = sortedTuples.map { $0.1 }
            self.dateSections = newDateSections
            self.dateData = newDateData
            self.transactions = newTransactions
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
            databaseHandleInProgress = false
        })
    }
    
    func doRecurringTransactions(recurringTransactions: [Transaction]) {
        for transaction in recurringTransactions {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let transactionDate = formatter.date(from: (transaction.date)!)
            var d: String = ""
            //start next cycle
            switch (transaction.recurType)! {
            case "day":
                d = formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: transactionDate!)!)
                break
            case "week":
                d = formatter.string(from: Calendar.current.date(byAdding: .day, value: 7, to: transactionDate!)!)
                break
            case "biweek":
                d = formatter.string(from: Calendar.current.date(byAdding: .day, value: 14, to: transactionDate!)!)
                break
            case "month":
                d = formatter.string(from: Calendar.current.date(byAdding: .month, value: 1, to: transactionDate!)!)
                break
            case "year":
                d = formatter.string(from: Calendar.current.date(byAdding: .year, value: 1, to: transactionDate!)!)
                break
            default:
                d = formatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: transactionDate!)!)
                break
            }
            let todayDate = Date()
            let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: todayDate) // += 1 day
                //for every day after given date
                //if d > lastLoginDate {
                while d < formatter.string(from: tomorrowDate!) {
                    if d > lastLogin {

                        let dbref = self.ref.child("users").child(self.user.uid).child("transactions").childByAutoId()
                        let dbkey = dbref.key
                        var recurringTransactionFound: Bool? = nil
                        //get next date transactions
                        if dateSections?.index(of: d) != nil && (dateData?[(dateSections?.index(of: d))!]) != nil{
                            print((dateData?[(dateSections?.index(of: d))!])!)
                            for t in (dateData?[(dateSections?.index(of: d))!])! {
                                //if theres a recurring transaction in DB and everything but key is the same
                                if t.recurring == true &&
                                    t.recurType == transaction.recurType &&
                                    t.amount == transaction.amount &&
                                    t.category == transaction.category &&
                                    t.note == transaction.note &&
                                    t.type == transaction.type {
                                    recurringTransactionFound = true
                                    break
                                }
                            }
                            if recurringTransactionFound == nil {
                                recurringTransactionFound = false
                            }
                        } else {
                            recurringTransactionFound = false
                        }
                        if recurringTransactionFound == false {
                            if !(dateSections?.contains(where: {$0 == d}))! {
                                dateSections?.append(d)
                                dateData?.append([transaction])
                            }
                            else {
                                dateData?[(dateSections?.index(of: (dateSections?.first(where: {$0 == d}))!))!].append(transaction)
                            }
                            let td: [String: Any] = [
                                "date": d,
                                "amount": transaction.amount ?? "",
                                "note": transaction.note ?? "",
                                "category": transaction.category ?? "",
                                "recurring": transaction.recurring ?? false,
                                "type": transaction.type ?? "",
                                "recurType": transaction.recurType ?? "",
                                "key": dbkey
                            ]
                            self.createNewTransaction(transaction: td, transactionID: dbref)
                            transactions.append(transaction)
                        }
                    }
                    //increment date
                    let newDate = formatter.date(from: d)
                    var nextDate: Date?
                    switch (transaction.recurType)! {
                    case "day":
                        nextDate = Calendar.current.date(byAdding: .day, value: 1, to: newDate!) // += 1 day
                        break
                    case "week":
                        nextDate = Calendar.current.date(byAdding: .day, value: 7, to: newDate!) // += 1 wk
                        break
                    case "biweek":
                        nextDate = Calendar.current.date(byAdding: .day, value: 14, to: newDate!) // += 2 wk
                        break
                    case "month":
                        nextDate = Calendar.current.date(byAdding: .month, value: 1, to: newDate!) // += 1 mo
                        break
                    case "year":
                        nextDate = Calendar.current.date(byAdding: .year, value: 1, to: newDate!) // += 1 yr
                        break
                    default:
                        nextDate = Calendar.current.date(byAdding: .day, value: 1, to: newDate!) // += 1 day
                        break
                    }
                    d = formatter.string(from: nextDate!)
                }
                //}
        }
    }
    
    deinit {
        if (databaseHandle != nil) {
            ref.child("users/\(self.user.uid)/transactions").removeObserver(withHandle: databaseHandle)
        }
    }
}
