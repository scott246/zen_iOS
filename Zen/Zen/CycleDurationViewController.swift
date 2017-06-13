//
//  CycleDurationViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/13/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// protocol used for sending data back
protocol CycleDataEnteredDelegate: class {
    func userDidEnterCycleInformation(info: String)
}

class CycleDurationViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: CycleDataEnteredDelegate? = nil
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // call this method on whichever class implements our delegate protocol
        switch indexPath.row {
        case 0:
            delegate?.userDidEnterCycleInformation(info: "Daily")
            break
        case 1:
            delegate?.userDidEnterCycleInformation(info: "Weekly")
            break
        case 2:
            delegate?.userDidEnterCycleInformation(info: "Biweekly")
            break
        case 3:
            delegate?.userDidEnterCycleInformation(info: "Monthly")
            break
        case 4:
            delegate?.userDidEnterCycleInformation(info: "Annually")
            break
        case 5:
            delegate?.userDidEnterCycleInformation(info: "Continuously")
            break
        default:
            break
        }
        
        // go back to the previous view controller
        _ = self.navigationController?.popViewController(animated: true)
    }
}
