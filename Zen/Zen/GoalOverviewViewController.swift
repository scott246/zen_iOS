//
//  GoalOverviewViewController.swift
//  Zen
//
//  Created by Nathan Scott on 7/2/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class GoalOverviewViewController: UICollectionViewController {
    override func viewDidLoad() {
        Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)/transactions").observeSingleEvent(of: .value, with: {(snapshot) in
            for itemSnapShot in snapshot.children {
                let transaction = Transaction(snapshot: itemSnapShot as! DataSnapshot)
                if transaction.type == "expense" {
                    for label in self.labels {
                        if transaction.category == label {
                            self.labelValues[self.labels.index(of: label)!] += Float(transaction.amount!)!
                        }
                    }
                }
            }
        })
        print(self.labelValues)
        self.navigationItem.setRightBarButton(
            UIBarButtonItem(title: "Edit Goals", style: .plain, target: self, action: #selector(didTapEditGoals)), animated: true)
    }
    func didTapEditGoals() {
        performSegue(withIdentifier: "editGoal", sender: nil)
    }
    
    var labels = ["Automotive & Transportation", "Bills & Utilities", "Business Services", "Charges & Fees", "Donations & Gifts", "Drinks & Social", "Education", "Entertainment", "Family & Children", "Food & Restaurants", "Health & Fitness", "Home", "Investments", "Payments & Loans", "Personal", "Pets", "Shopping", "Taxes", "Travel", "Other"]
    var labelValues: [Float] = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.labels.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "goalCell", for: indexPath) as! GoalOverviewCell
        cell.goalCategory.text = labels[indexPath.row]
        Database.database().reference().child("users/\((Auth.auth().currentUser?.uid)!)/goals").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            let goalFloat = value?[self.labels[indexPath.row]] as? Float ?? 0.0
            let goal = String(describing: (value?[self.labels[indexPath.row]])!)
            let progressFloat = self.labelValues[indexPath.row]
            let progress = String(describing: self.labelValues[indexPath.row])
            cell.goalProgressLabel.text = progress + "/" + goal
            cell.goalProgress.progress = progressFloat / goalFloat
            if cell.goalProgress.progress > 0.75 {
                cell.goalProgress.tintColor = UIColor.red
            }
            else {
                cell.goalProgress.tintColor = UIColor.blue
            }
        })
        return cell
    }
}
