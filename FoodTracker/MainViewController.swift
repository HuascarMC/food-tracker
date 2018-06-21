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
    @IBOutlet weak var BarChart: BarChartView!
    
    var db: Firestore!
    let months = ["Previous", "Previous", "PrevDay", "Yesterday", "Today"]
    let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0]
    let unitsBought = [10.0, 14.0, 60.0, 13.0, 2.0]
    var currentDate: Date?
    var yesterday: Date?
    var days = [
        "previousx1" : 0,
        "beforeYesterday" : 0,
        
         "previousx2" : 0,
         "today" : 0,
         "yesterday" : 0
        
        ]
    
    var genders = [
        "male1" : 7,
        "female1": 4,
        "male2" : 6,
        "female2" : 3,
        "male3" : 9,
        "female3" : 5,
        "male4" : 5,
        "female4" : 2
    ]
    let dateFormatter = DateFormatter()
    
    override func viewWillAppear(_ animated: Bool) {
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
        self.setDates()
        getVisitors5Days(completion: updateLineChart)
    }
    
    
    private func setDates() {
        let date = NSDate()
        self.currentDate = formatDate(date: date as Date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        updateLineChart()

        // Do any additional setup after loading the view.
    
    

    setChart()
}

func setChart() {
    //legend
    let legend = BarChart.legend
    legend.enabled = true
    legend.horizontalAlignment = .right
    legend.verticalAlignment = .top
    legend.orientation = .vertical
    legend.drawInside = true
    legend.yOffset = 10.0;
    legend.xOffset = 10.0;
    legend.yEntrySpace = 0.0;
    legend.textColor = UIColor.white;
    
    
    let xaxis = BarChart.xAxis
    xaxis.drawGridLinesEnabled = true
    xaxis.labelPosition = .bottom
    xaxis.centerAxisLabelsEnabled = true
    xaxis.valueFormatter = IndexAxisValueFormatter(values:self.months)
    xaxis.granularity = 1
    
    
    let leftAxisFormatter = NumberFormatter()
    leftAxisFormatter.maximumFractionDigits = 1
    
    let yaxis = BarChart.leftAxis
    yaxis.spaceTop = 0.35
    yaxis.axisMinimum = 0
    yaxis.drawGridLinesEnabled = false
    
    BarChart.rightAxis.enabled = false
    //axisFormatDelegate = self
    
    var dataEntries: [BarChartDataEntry] = []
    var dataEntries1: [BarChartDataEntry] = []
    
    let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
                               font: .systemFont(ofSize: 15),
                               textColor: .white,
                               insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
    marker.chartView = BarChart
    marker.minimumSize = CGSize(width: 80, height: 40)
    BarChart.marker = marker
    
    
    let xAxis = BarChart.xAxis
    xAxis.labelPosition = .bottom
    xAxis.labelFont = .systemFont(ofSize: 10)
    xAxis.labelTextColor = UIColor(white:1, alpha: 1)
    xAxis.axisLineWidth = 3.0
    xAxis.axisLineColor = UIColor(white: 1, alpha: 1)
    
    let leftAxis = BarChart.leftAxis
    leftAxis.removeAllLimitLines()
    //        leftAxis.addLimitLine(ll1)
    //        leftAxis.addLimitLine(ll2)
//    leftAxis.axisMaximum = 10
//    leftAxis.axisMinimum = 0
    leftAxis.gridLineDashLengths = [5, 5]
    leftAxis.minWidth = 3.0
    leftAxis.labelTextColor = UIColor(white: 1, alpha: 1)
    leftAxis.axisLineWidth = 3.0
    leftAxis.axisLineColor = UIColor(white: 1, alpha: 1)
    leftAxis.drawLimitLinesBehindDataEnabled = true

    var ind = 0
    for (_, value) in self.genders {
        
        let dataEntry = BarChartDataEntry(x: Double(ind) , y: Double(value))
        dataEntries.append(dataEntry)
        ind += 1
        let dataEntry1 = BarChartDataEntry(x: Double(ind) , y: Double(value))
        dataEntries1.append(dataEntry1)
        
        //stack barchart
        //let dataEntry = BarChartDataEntry(x: Double(i), yValues:  [self.unitsSold[i],self.unitsBought[i]], label: "groupChart")
    }
    
    let chartDataSet = BarChartDataSet(values: dataEntries, label: "Male")
    let chartDataSet1 = BarChartDataSet(values: dataEntries1, label: "Female")
    
    let dataSets: [BarChartDataSet] = [chartDataSet,chartDataSet1]
    chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
    //chartDataSet.colors = ChartColorTemplates.colorful()
    //let chartData = BarChartData(dataSet: chartDataSet)
    
    let chartData = BarChartData(dataSets: dataSets)
    
    
    let groupSpace = 0.3
    let barSpace = 0.05
    let barWidth = 0.3
    // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"
    
    let groupCount = self.months.count
    let startYear = 0
    
    
    chartData.barWidth = barWidth;
    BarChart.xAxis.axisMinimum = Double(startYear)
    let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
    print("Groupspace: \(gg)")
    BarChart.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
    
    chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
    //chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
    BarChart.notifyDataSetChanged()
    
    BarChart.data = chartData
    
    
    
    
    
    
    //background color
//    BarChart.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
    
    //chart animation
    BarChart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
    
    
}


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateLineChart() {
        print("asdfasidjfnaskdfjnalsdkjfnaldkfjnalkdjfnalkdjfnalksdjfnaskldjfnalskdfjna")
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
        formatter.nameValues = ["", "Previous", "Previous", "PrevYday", "Yesterday", "Today"] //anything you want
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

        var index = 0
        for (e, value) in days.reversed()  {
            let entry = ChartDataEntry(x: Double(index), y: Double(value))
            lineChartEntry.append(entry)
            index += 1
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
    
    private func getVisitors5Days(completion: () -> ()) {
        getVisitorsByDate(date: currentDate!) { (result) in
            print(result)
            self.days["today"] = result
            self.updateLineChart()
        }


        let yesterday = self.getYesterdayDate(date: self.currentDate!)
        getVisitorsByDate(date: yesterday) { (result) in
            print(result)
            self.days["beforeYesterday"] = result
            self.updateLineChart()
        }

        let beforeYesterday = self.getYesterdayDate(date: yesterday)
        getVisitorsByDate(date: beforeYesterday) { (result) in
            print(result)
            self.days["yesterday"] = result
            self.updateLineChart()
        }

        let bby = self.getYesterdayDate(date: beforeYesterday)
        getVisitorsByDate(date: bby) { (result) in
            print(result)
            self.days["previousx1"] = result
            self.updateLineChart()
        }

        let bbby = self.getYesterdayDate(date: bby)
        getVisitorsByDate(date: bbby) { (result) in
            self.days["previousx2"] = result
            self.updateLineChart()
        }
        print("a0000000000245245245235234523452345234523452352345234524")
        
        completion()

    }
    
    private func getVisitorsByDate(date: Date, finished: @escaping (_ result: Int) -> Void) {
        var visitorsCount = 0
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
                          finished(visitorsCount)
                    }
                 
                }
        }
      
    }
    

    
//    private func getVisitorsByDateAndGender(date: Date, gender: String) {
//        var visitorsCount = Double(0)
//        db.collection("visitors").whereField("date", isEqualTo: date)
//            .getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//
//                } else {
//                    if(!(querySnapshot?.isEmpty)!) {
//                        for document in querySnapshot!.documents {
//                            if(document.data.gender == gender) {
//                                print("\(document.documentID) => \(document.data())")
//                                visitorsCount += 1
//                                // [END get_multiple]
//                            }
//                        }
//                    }
//                    return visitorsCount
//                }
//        }
//    }
    
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
