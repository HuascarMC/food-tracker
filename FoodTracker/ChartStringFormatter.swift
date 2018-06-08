//
//  ChartStringFormatter.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 08/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import Foundation
import Charts

class ChartStringFormatter: NSObject, IAxisValueFormatter {
    
    var nameValues: [String]! =  ["A", "B", "C", "D"]
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(describing: nameValues[Int(value)])
    }
}
