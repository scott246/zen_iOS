//
//  AnalysisViewCell.swift
//  Zen
//
//  Created by Nathan Scott on 7/2/17.
//  Copyright © 2017 Nathan Scott. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase
import Charts

class AnalysisBarViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chartTitle: UILabel!
    @IBOutlet weak var chartView: BarChartView!

}

class AnalysisLineViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chartTitle: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    
}

class AnalysisPieViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chartTitle: UILabel!
    @IBOutlet weak var chartView: PieChartView!
    
}

class AnalysisViewCell: UICollectionViewCell {
    
    @IBOutlet weak var chartTitle: UILabel!
    @IBOutlet weak var chartView: BarChartView!
    
}
