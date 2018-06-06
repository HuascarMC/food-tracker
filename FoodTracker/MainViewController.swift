//
//  MainViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 05/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit
import Charts

class MainViewController: UIViewController {
    @IBOutlet weak var lineChart: LineChartView!
    
    var visitorsCount = [Double](arrayLiteral: 3, 1, 2, 5, 3)
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLineChart()
        // Do any additional setup after loading the view.
        updateLineChart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateLineChart() {
        var lineChartEntry = [ChartDataEntry]()
        
        for i in 0..<visitorsCount.count {
            let entry = ChartDataEntry(x: Double(i), y: visitorsCount[i])
            
            lineChartEntry.append(entry)
        }
        
        let line = LineChartDataSet(values: lineChartEntry, label: "Visitors")
        
        line.colors = [NSUIColor.orange]
        
        let data = LineChartData()
        data.addDataSet(line)
              lineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        lineChart.data = data
        lineChart.chartDescription?.text = "Visitors in past 5 days"
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
