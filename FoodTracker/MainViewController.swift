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
            if(visitorsByDay.count == 5) {
                visitorsByDay.swapAt(2, 3)
                updateLineChart()
            }
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
//        updateLineChart()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateLineChart() {
    
        var lineChartEntry = [ChartDataEntry]()
        lineChart.chartDescription?.enabled = false
        lineChart.dragEnabled = true
        lineChart.setScaleEnabled(true)
        lineChart.pinchZoomEnabled = true
        lineChart.gridBackgroundColor = UIColor(white: 1, alpha: 1)
        
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.labelTextColor = UIColor(white:1, alpha: 1)
        xAxis.axisLineWidth = 3.0
        xAxis.axisLineColor = UIColor(white: 1, alpha: 1)
        
        // x-axis limit line
        let llXAxis = ChartLimitLine(limit: 10, label: "Index 10")
        llXAxis.lineWidth = 4
        llXAxis.lineDashLengths = [10, 10, 0]
        llXAxis.labelPosition = .rightBottom
        llXAxis.valueFont = .systemFont(ofSize: 10)
        
        lineChart.xAxis.gridLineDashLengths = [10, 10]
        lineChart.xAxis.gridLineDashPhase = 0
        let formatter = ChartStringFormatter()
        formatter.nameValues = ["", "", "Previous", "Previous", "Yesterday", "Today"] //anything you want
        xAxis.valueFormatter = formatter
        xAxis.granularity = 1
        
        let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                                   font: .systemFont(ofSize: 15),
                                   textColor: .white,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = lineChart
        marker.minimumSize = CGSize(width: 80, height: 40)
        lineChart.marker = marker
        
        lineChart.legend.form = .line
//
//        let ll1 = ChartLimitLine(limit: 150, label: "Upper Limit")
//        ll1.lineWidth = 4
//        ll1.lineDashLengths = [5, 5]
//        ll1.labelPosition = .rightTop
//        ll1.valueFont = .systemFont(ofSize: 10)
//
//        let ll2 = ChartLimitLine(limit: -30, label: "Lower Limit")
//        ll2.lineWidth = 4
//        ll2.lineDashLengths = [5,5]
//        ll2.labelPosition = .rightBottom
//        ll2.valueFont = .systemFont(ofSize: 10)
        let gradientColors = [ChartColorTemplates.colorFromString("#00ff0000").cgColor,
                             ChartColorTemplates.colorFromString("#ffff0000").cgColor]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
        
    
        
        let leftAxis = lineChart.leftAxis
        leftAxis.removeAllLimitLines()
//        leftAxis.addLimitLine(ll1)
//        leftAxis.addLimitLine(ll2)
        leftAxis.axisMaximum = 10
        leftAxis.axisMinimum = 0
        leftAxis.gridLineDashLengths = [5, 5]
        leftAxis.minWidth = 3.0
        leftAxis.labelTextColor = UIColor(white: 1, alpha: 1)
        leftAxis.axisLineWidth = 3.0
        leftAxis.axisLineColor = UIColor(white: 1, alpha: 1)
        leftAxis.drawLimitLinesBehindDataEnabled = true
        
        lineChart.rightAxis.enabled = false

        
        for i in 0..<self.visitorsByDay.count {
            let entry = ChartDataEntry(x: Double(i), y: self.visitorsByDay[i])
            lineChartEntry.append(entry)
        }
        
        let line = LineChartDataSet(values: lineChartEntry, label: "Visitors")
        
        line.colors = ChartColorTemplates.colorful()
        line.setCircleColors(UIColor(red: 0, green: 1, blue: 0, alpha: 1))
        line.lineDashLengths = [5, 2.5]
        line.highlightLineDashLengths = [5, 2.5]
//        line.setColor(.black)
        line.setCircleColor(.orange)
        line.lineWidth = 10
        line.circleRadius = 10
        line.drawCircleHoleEnabled = false
        line.valueFont = .systemFont(ofSize: 0)
        line.formLineDashLengths = [5, 2.5]
        line.formLineWidth = 1
        line.formSize = 15
        line.fillAlpha = 1
        line.fill = Fill(linearGradient: gradient, angle: 90) //.linearGradient(gradient, angle: 90)
        line.drawFilledEnabled = true
        let data = LineChartData()
        data.addDataSet(line)
        lineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        lineChart.data = data
        lineChart.rightAxis.enabled = false
        lineChart.legend.enabled = false
        lineChart.borderLineWidth = 1.0
    
        
   
        lineChart.chartDescription?.text = "Visitors in past 3 days"
    }
    
    private func getVisitorsPastThreeDays() {
        self.visitorsByDay.removeAll()
        getVisitorsByDate(date: self.currentDate!)
        getVisitorsByDate(date: self.yesterday!)
        getVisitorsByDate(date: self.beforeYesterday!)
        let bby = self.getYesterdayDate(date: self.beforeYesterday!)
        getVisitorsByDate(date: bby)
        let bbby = self.getYesterdayDate(date: bby)
        getVisitorsByDate(date: bbby)
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
