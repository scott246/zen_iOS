//
//  AnalysisViewController.swift
//  Zen
//
//  Created by Nathan Scott on 7/2/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import Charts

class AnalysisViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ChartViewDelegate {
    
    var charts = ["Spending by Month", "Spending by Category", "Income by Month", "Income - Expenses"]
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.charts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "barAnalysisCell", for: indexPath as IndexPath) as! AnalysisBarViewCell
            cell.chartTitle.text = charts[indexPath.row]
            //do stuff to the cell

            var dataEntries: [BarChartDataEntry] = []
            
            for i in 1..<months.count+1 {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(totalSpending[i-1]), data: months as AnyObject)
                dataEntries.append(dataEntry)
            }
            let label = ("Budget (" + currency + String(describing: budget) + ")")
            let targetLine = ChartLimitLine(limit: Double(budget), label: label)
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Amount Spent")
            let chartData = BarChartData()
            chartData.addDataSet(chartDataSet)
            cell.chartView.data = chartData
            if budget > 0.0{
                cell.chartView.leftAxis.addLimitLine(targetLine)
            }
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "pieAnalysisCell", for: indexPath as IndexPath) as! AnalysisPieViewCell
            cell.chartTitle.text = charts[indexPath.row]
            //do stuff to the cell
            
            var dataEntries: [PieChartDataEntry] = []
            
            for i in 0..<expenseFields.count {
                if expenseValues[i] > 0 {
                    let dataEntry = PieChartDataEntry(value: Double(expenseValues[i]), label: expenseFields[i])
                    dataEntries.append(dataEntry)
                }
            }
            let chartDataSet = PieChartDataSet(values: dataEntries, label: "")
            chartDataSet.colors = ChartColorTemplates.liberty()
            chartDataSet.entryLabelColor = UIColor.black
            chartDataSet.valueColors = [UIColor.black]
            let chartData = PieChartData()
            chartData.addDataSet(chartDataSet)
            cell.chartView.data = chartData
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "barAnalysisCell", for: indexPath as IndexPath) as! AnalysisBarViewCell
            cell.chartTitle.text = charts[indexPath.row]
            //do stuff to the cell
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 1..<months.count+1 {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(totalIncome[i-1]), data: months as AnyObject)
                dataEntries.append(dataEntry)
            }
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Amount Spent")
            let chartData = BarChartData()
            chartData.addDataSet(chartDataSet)
            cell.chartView.data = chartData
            return cell
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "barAnalysisCell", for: indexPath as IndexPath) as! AnalysisBarViewCell
            cell.chartTitle.text = charts[indexPath.row]
            //do stuff to the cell
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 1..<months.count+1 {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(totalIncome[i-1] - totalSpending[i-1]), data: months as AnyObject)
                dataEntries.append(dataEntry)
            }
            let chartDataSet = BarChartDataSet(values: dataEntries, label: "Incomes - Expenses")
            let chartData = BarChartData()
            chartData.addDataSet(chartDataSet)
            cell.chartView.data = chartData
            return cell
        default:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "analysisCell", for: indexPath as IndexPath)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
    }
    
    override func viewDidLoad() {
        navigationController?.navigationBar.barTintColor = UIColor(red: 60/255, green: 180/255, blue: 60/255, alpha: 0)
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        tabBarController?.tabBar.barTintColor = UIColor(red: 60/255, green: 180/255, blue: 60/255, alpha: 0)
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.black
        tabBarController?.tabBar.tintColor = UIColor.white
        self.collectionView?.reloadData()
    }
    let months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
    var totalSpending: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    var totalIncome: [Float] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    var budget: Float = 0.0
    var expenseFields = ["Uncategorized", "Automotive & Transportation", "Bills & Utilities", "Business Services", "Charges & Fees", "Donations & Gifts", "Drinks & Social", "Education", "Entertainment", "Family & Children", "Food & Restaurants", "Health & Fitness", "Home", "Investments", "Payments & Loans", "Personal", "Pets", "Shopping", "Taxes", "Travel", "Other"]
    var expenseValues: [Float] = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    override func viewDidAppear(_ animated: Bool) {
        totalSpending = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        budget = 0.0
        expenseValues = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        totalIncome = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)/transactions").observeSingleEvent(of: .value, with: {(snapshot) in
            for itemSnapShot in snapshot.children {
                let transaction = Transaction(snapshot: itemSnapShot as! DataSnapshot)
                let df = DateFormatter()
                df.dateFormat = "yyyy"
                let y = df.string(from: Date())
                if transaction.type == "expense" && (transaction.date?.contains(y))! {
                    for label in self.months {
                        if (transaction.date?.contains(y + "-" + label))! {
                            self.totalSpending[self.months.index(of: label)!] += Float(transaction.amount!)!
                            let df2 = DateFormatter()
                            df2.dateFormat = "MM"
                            let m = df2.string(from: Date())
                            if label == m {
                                for ef in self.expenseFields {
                                    if transaction.category == ef {
                                        self.expenseValues[self.expenseFields.index(of: ef)!] += Float(transaction.amount!)!
                                    }
                                }
                            }
                        }
                    }
                }
                if (transaction.type == "income" || transaction.type == "savings") && (transaction.date?.contains(y))! {
                    for label in self.months {
                        if (transaction.date?.contains(y + "-" + label))! {
                            self.totalIncome[self.months.index(of: label)!] += Float(transaction.amount!)!
                        }
                    }
                }
            }
            self.collectionView?.reloadData()
        })
        Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)/goals").observeSingleEvent(of: .value, with: {(snapshot) in
            for itemSnapShot in snapshot.children {
                let ds = itemSnapShot as! DataSnapshot
                let data = ds.value as! Float
                self.budget += data
            }
            self.collectionView?.reloadData()
        })
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 16, height: 300)
    }
    @IBOutlet weak var analysisCollection: UICollectionView!
}
