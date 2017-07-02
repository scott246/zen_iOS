//
//  Setup2ViewController.swift
//  Zen
//
//  Created by Nathan Scott on 7/1/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class Setup2ViewController: UIViewController {
    
    @IBOutlet weak var savingsSlider: UISlider!
    @IBAction func sliderChanged(_ sender: Any) {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        savingsLabel.text = formatter.string(from: NSNumber(value: savingsSlider.value * 100))! + "%"
    }
    @IBOutlet weak var savingsLabel: UILabel!
    @IBAction func nextButtonClicked(_ sender: Any) {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        savings = formatter.number(from: formatter.string(from: NSNumber(value: savingsSlider.value * 100))!) as! Float
        Database.database().reference().updateChildValues(["/users/\((Auth.auth().currentUser?.uid)!)/savings": savings])
        performSegue(withIdentifier: "toSetup3", sender: nil)
    }

    override func viewDidLoad() {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        savingsLabel.text = formatter.string(from: NSNumber(value: savingsSlider.value * 100))! + "%"
    }
}
