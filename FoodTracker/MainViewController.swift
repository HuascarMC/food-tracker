//
//  MainViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 05/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit
import Firebase
import Charts

class MainViewController: UIViewController {
    @IBOutlet weak var lineChart: LineChartView!
    
    var db: Firestore!
    var currentDate: Date?
    let dateFormatter = DateFormatter()
    var visitorsByDay = [Double]() {
        didSet {
            updateLineChart()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = NSDate()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let dateString = dateFormatter.string(from: date as Date)
        self.currentDate = dateFormatter.date(from: dateString)
        getVisitorsPastThreeDays()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLineChart()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateLineChart() {
        var lineChartEntry = [ChartDataEntry]()
        
        for i in 0..<self.visitorsByDay.count {
            let entry = ChartDataEntry(x: Double(i), y: self.visitorsByDay[i])
            
            lineChartEntry.append(entry)
        }
        
        let line = LineChartDataSet(values: lineChartEntry, label: "Visitors")
        
        line.colors = ChartColorTemplates.colorful()
        
        let data = LineChartData()
        data.addDataSet(line)
              lineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        lineChart.data = data
   
        lineChart.chartDescription?.text = "Visitors in past 5 days"
    }
    
    private func getVisitorsPastThreeDays() {
        getVisitorsByDate(date: self.currentDate!)
        getVisitorsByDate(date: dateFormatter.date(from: "2018-06-05")!)
        getVisitorsByDate(date: dateFormatter.date(from: "2018-06-04")!)
    }
    
    private func getVisitorsByDate(date: Date) {
        var visitorsCount = Double(0)
        db.collection("visitors").whereField("date", isEqualTo: date)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                    if(!(querySnapshot?.isEmpty)!) {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            visitorsCount += 1
                            // [END get_multiple]
                        }
                    }
                    self.visitorsByDay.append(visitorsCount)
                }
        }
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
