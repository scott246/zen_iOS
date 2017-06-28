//
//  SavingsViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/26/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

var savings:Float = 0.0

class SavingsViewController: UIViewController {
    var user: User!
    var ref: DatabaseReference!
    @IBOutlet weak var savingsLabel: UILabel!
    @IBOutlet weak var savingsSlider: UISlider!
    @IBAction func sliderMoved(_ sender: Any) {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        savingsLabel.text = formatter.string(from: NSNumber(value: savingsSlider.value * 100))! + "%"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        user = Auth.auth().currentUser
        ref = Database.database().reference()
        savingsSlider.value = savings/100
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        savingsLabel.text = formatter.string(from: NSNumber(value: savingsSlider.value * 100))! + "%"
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDone)), animated: true)
    }
    
    func didTapDone() {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.minimumIntegerDigits = 1
        savings = formatter.number(from: formatter.string(from: NSNumber(value: savingsSlider.value * 100))!) as! Float
        ref.updateChildValues(["/users/\(self.user.uid)/savings": savings])
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
