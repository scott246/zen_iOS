//
//  RecordsSearchTableViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/17/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RecordsSearchTableViewController: UITableViewController, EditDataEnteredDelegate {
    var dateData: [[Transaction]] = [[]]
    var filteredDateData: [[Transaction]] = [[]]
    var dateSections: [String] = []
    var filteredDateSections: [String] = []
    var transactions: [Transaction] = []
    var filteredTransactions: [Transaction] = []
    var searchField: UITextField? = nil
    
    weak var delegate: EditDataEnteredDelegate? = nil
    
    func refreshSearch() {
        filteredDateData = dateData
        filteredDateSections = dateSections
        filteredTransactions = transactions
        if searchField?.text == nil {
            return
        }
        var outerPos = 0
        for t in (filteredDateData) {
            var pos = 0
            for i in t {
                if !(i.note?.lowercased().contains((searchField?.text!.lowercased())!))! {
                    filteredDateData[outerPos].remove(at: pos)
                    filteredTransactions.remove(at: outerPos + pos)
                    pos -= 1
                }
                pos += 1
            }
            if (filteredDateData[outerPos].count == 0) {
                filteredDateData.remove(at: outerPos)
                filteredDateSections.remove(at: outerPos)
                outerPos -= 1
            }
            outerPos += 1
        }
        self.tableView.reloadData()
    }
    var ref: DatabaseReference? = nil
    override func viewDidLoad() {
        ref = Database.database().reference()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return (filteredDateSections.count)
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (filteredDateSections[section])
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredDateData[section].count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        self.filteredTransactions.sort(by: {
            df.date(from: $0.date!)! > df.date(from: $1.date!)!
        })
        
        var row = 0
        let ipsec = indexPath.section
        var currsec = 0
        let iprow = indexPath.row
        
        while currsec < ipsec {
            row += tableView.numberOfRows(inSection: currsec)
            currsec += 1
        }
        row += iprow
        
        let transaction = self.filteredTransactions[row]
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
        return filteredDateSections
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
            let transaction = filteredTransactions[row]
            transaction.ref?.removeValue()
            _ = self.navigationController?.popViewController(animated: true)
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
        let cellAmount = filteredTransactions[row].amount
        let cellDate = filteredTransactions[row].date
        let cellCategory = filteredTransactions[row].category
        var cellRecurring: String?
        if filteredTransactions[row].recurring! {
            cellRecurring = "true"
        }
        else {
            cellRecurring = "false"
        }
        let cellNote = filteredTransactions[row].note
        let cellType = filteredTransactions[row].type
        let cellRecurType = filteredTransactions[row].recurType
        let theSender = [cellAmount!, cellCategory!, cellDate!, cellNote!, cellRecurring!, cellRecurType!, cellType!]
        performSegue(withIdentifier: "toDetail", sender: theSender)
        changeKey = filteredTransactions[row].key
    }
    
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
        let childUpdates = ["/users/\(Auth.auth().currentUser!.uid)/transactions/\(id)/": post]
        ref?.updateChildValues(childUpdates)
        _ = self.navigationController?.popViewController(animated: true)
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
    }
    
}
