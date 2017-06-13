//
//  CurrencySelectorViewController.swift
//  Zen
//
//  Created by Nathan Scott on 6/12/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// protocol used for sending data back
protocol CurrencyDataEnteredDelegate: class {
    func userDidEnterCurrencyInformation(info: String)
}


class CurrencySelectorViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // making this a weak variable so that it won't create a strong reference cycle
    weak var delegate: CurrencyDataEnteredDelegate? = nil
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // call this method on whichever class implements our delegate protocol
        switch indexPath.row {
        case 0:
            delegate?.userDidEnterCurrencyInformation(info: "$")
            break
        case 1:
            delegate?.userDidEnterCurrencyInformation(info: "£")
            break
        case 2:
            delegate?.userDidEnterCurrencyInformation(info: "€")
            break
        case 3:
            delegate?.userDidEnterCurrencyInformation(info: "¥")
            break
        case 4:
            delegate?.userDidEnterCurrencyInformation(info: "₩")
            break
        case 5:
            delegate?.userDidEnterCurrencyInformation(info: "¤")
            break
        case 6:
            delegate?.userDidEnterCurrencyInformation(info: "₿")
            break
        default:
            break
        }
            
        // go back to the previous view controller
        _ = self.navigationController?.popViewController(animated: true)
    }
}
