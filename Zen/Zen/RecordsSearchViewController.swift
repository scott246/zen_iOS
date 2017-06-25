//
//  RecordsSearchViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/17/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RecordsSearchViewController: UIViewController {
    
    weak var delegate: EditDataEnteredDelegate? = nil

    @IBOutlet weak var searchField: UITextField!
    @IBAction func searchFunction(_ sender: Any) {
        print("search refreshed")
        embedVC?.searchField = searchField
        embedVC?.refreshSearch()
    }
    @IBOutlet weak var searchTable: UIView!
    
    weak var embedVC:RecordsSearchTableViewController?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            let detailScene = segue.destination as! RecordsSearchTableViewController
            self.embedVC = detailScene
            self.embedVC?.dateData = dateData
            self.embedVC?.dateSections = dateSections
            self.embedVC?.transactions = transactions
            self.embedVC?.searchField = searchField
        }
    }
    var dateData: [[Transaction]] = [[]]
    var dateSections: [String] = []
    var transactions: [Transaction] = []
}
