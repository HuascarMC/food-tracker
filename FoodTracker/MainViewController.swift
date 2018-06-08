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
    var yesterday: Date?
    var beforeYesterday: Date? {
        didSet {
            getVisitorsPastThreeDays()
        }
    }
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
        visitorsByDay.removeAll()
        self.setDates()
    }
    
    private func setDates() {
        let date = NSDate()
        self.currentDate = formatDate(date: date as Date)
        self.yesterday = getYesterdayDate(date: self.currentDate!)
        self.beforeYesterday = getYesterdayDate(date: self.yesterday!)
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
            let entry = ChartDataEntry(x: Double(i), y: self.visitorsByDay.reversed()[i])
            
            lineChartEntry.append(entry)
        }
        
        let line = LineChartDataSet(values: lineChartEntry, label: "Visitors")
        
        line.colors = ChartColorTemplates.colorful()
        
        let data = LineChartData()
        data.addDataSet(line)
        lineChart.xAxis.labelPosition = .bottom
        lineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        lineChart.data = data
   
        lineChart.chartDescription?.text = "Visitors in past 5 days"
    }
    
    private func getVisitorsPastThreeDays() {
        getVisitorsByDate(date: self.currentDate!)
        getVisitorsByDate(date: self.yesterday!)
        getVisitorsByDate(date: self.beforeYesterday!)
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
    
    private func getYesterdayDate(date: Date) -> Date {
        let daysToAdd = -1
        let currentDate = date
        
        var dateComponent = DateComponents()
        
        dateComponent.day = daysToAdd
        
        let yesterdayDate = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        return yesterdayDate!
    }
    
    private func formatDate(date: Date) -> Date{
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = date
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let dateString = dateFormatter.string(from: date)
        let formattedDate = dateFormatter.date(from: dateString)
        return formattedDate!
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
