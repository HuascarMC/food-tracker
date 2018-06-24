//
//  DataViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 03/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit
import Firebase
import Charts

class DataViewController: UIViewController {
  
    @IBOutlet weak var visitorsCountLabel: UITextView!
    @IBOutlet weak var malesCountLabel: UILabel!
    @IBOutlet weak var femalesCountLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var BarChart: BarChartView!
    
    let ages = ["0-10", "11-20", "21-30", "31-40", "41-50", "51-60", "61-70"]
    let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0]
    let unitsBought = [10.0, 14.0, 60.0, 13.0, 2.0]
    var db: Firestore!
    var currentDate: Date?
    let dateFormatter = DateFormatter()
    var totalVisitors: Double?
    var agesCount = [
        "10" : 0,
        "20": 0,
        "30" : 0,
        "40" : 0,
        "50" : 0,
        "60" : 0,
        "70" : 0,
    ]
    var malesCount = Double(0) {
        didSet {
            self.updatePieChart()
            self.visitorsCountLabel.text = String(self.malesCount + self.femalesCount)
        }
    }
    var femalesCount = Double(0) {
        didSet {
            self.updatePieChart()
            self.visitorsCountLabel.text = String(self.malesCount + self.femalesCount)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let date = datePicker.date
        self.currentDate = formatDate(date: date)
        
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
        self.getTotals()
        getVisitorsByAges {
            setChart()
        }
    }
    
    private func resetAgesCount() {
        self.agesCount["10"] = 0
        self.agesCount["20"] = 0
        self.agesCount["30"] = 0
        self.agesCount["40"] = 0
        self.agesCount["50"] = 0
        self.agesCount["60"] = 0
        self.agesCount["70"] = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updatePieChart()
        datePicker.setValue(UIColor.white, forKeyPath: "textColor")
        BarChart.rightAxis.enabled = false
        //axisFormatDelegate = self
        

    }
    
    func setChart() {
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.maximumFractionDigits = 1
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
        
        BarChart.noDataText = "You need to provide data for the chart."
        var dataEntries: [BarChartDataEntry] = []
//        var dataEntries1: [BarChartDataEntry] = []
        
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
//        xAxis.granularityEnabled = true
//        xAxis.granularity = 1
//        xAxis.xOffset = 0
//        xAxis.drawGridLinesEnabled = true
//        xAxis.labelPosition = .bottom
//        xAxis.centerAxisLabelsEnabled = true
        xAxis.valueFormatter = IndexAxisValueFormatter(values:self.ages)
//        xAxis.granularity = 1
//        xAxis.granularityEnabled = true
//
        
        let greatestHue = self.agesCount.max { a, b in a.value < b.value }
        
        let yAxis = BarChart.leftAxis
        yAxis.removeAllLimitLines()
        //        leftAxis.addLimitLine(ll1)
        //        leftAxis.addLimitLine(ll2)
        //    leftAxis.axisMaximum = 10
        //    leftAxis.axisMinimum = 0
        yAxis.gridLineDashLengths = [5, 5]
        yAxis.minWidth = 3.0
        yAxis.labelTextColor = UIColor(white: 1, alpha: 1)
        yAxis.axisLineWidth = 3.0
        yAxis.axisLineColor = UIColor(white: 1, alpha: 1)
        yAxis.drawLimitLinesBehindDataEnabled = true
        yAxis.spaceTop = 0.35
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = Double(((greatestHue?.value)! + 5))
        yAxis.drawGridLinesEnabled = false
        
        var ind = 0 
        for (e, value) in self.agesCount {
            
            let dataEntry = BarChartDataEntry(x: Double(ind) , y: Double(value))
            dataEntries.append(dataEntry)
            
//            let dataEntry1 = BarChartDataEntry(x: Double(ind) , y: Double(value))
//            dataEntries1.append(dataEntry1)
            
            ind += 1
            //stack barchart
            //let dataEntry = BarChartDataEntry(x: Double(i), yValues:  [self.unitsSold[i],self.unitsBought[i]], label: "groupChart")
            
            
            
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "")
//        let chartDataSet1 = BarChartDataSet(values: dataEntries1, label: "Female")
        
        let dataSets: [BarChartDataSet] = [chartDataSet]
//        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        chartDataSet.colors = ChartColorTemplates.colorful()
        //let chartData = BarChartData(dataSet: chartDataSet)
        
        let chartData = BarChartData(dataSets: dataSets)
        
        
//        let groupSpace = 0.3
//        let barSpace = 0.05
//        let barWidth = 1
        // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"
        
//        let groupCount = self.ages.count
//        let startYear = 0
        
        
//        chartData.barWidth = 0.5
//        chartData.groupWidth(groupSpace: 1.0, barSpace: 2.0)
//        BarChart.xAxis.axisMinimum = Double(startYear)
//        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
//        print("Groupspace: \(gg)")
//        BarChart.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        
//        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
//        chartData.groupWidth(groupSpace: 20, barSpace: 20)
        BarChart.notifyDataSetChanged()
        
        BarChart.data = chartData
        
        
        
        
        
        
        //background color
        //    BarChart.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        //chart animation
        BarChart.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
        
        
    }

    
    private func getTotals() {
        self.getTotalMales()
        self.getTotalFemales()
    }
    
    private func getTotalMales() {
        db.collection("visitors").whereField("gender", isEqualTo: "male").whereField("date", isEqualTo: self.currentDate!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                    self.malesCount = 0
                    if(!(querySnapshot?.isEmpty)!) {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.malesCount += 1
                        // [END get_multiple]
                    }
                }
//                self.malesCountLabel.text = String(self.malesCount)
          }
        }
 
    }
    
    private func getTotalFemales() {
        db.collection("visitors").whereField("gender", isEqualTo: "female").whereField("date", isEqualTo: self.currentDate!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    self.femalesCount = 0
                    if(!(querySnapshot?.isEmpty)!) {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.femalesCount += 1
                        // [END get_multiple]
                        }
                 }
//                    self.femalesCountLabel.text = String(self.femalesCount)
                }
        }
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func search(_ sender: Any) {
        resetAgesCount()
        let dateString = dateFormatter.string(from: datePicker.date as Date)
        self.currentDate = dateFormatter.date(from: dateString)
        self.getTotals()
        getVisitorsByAges {
            setChart()
        }
    }
    
    
    private func getVisitorsByAges(completion: () -> ()) {
        getVisitorsByDateAndAge(date: currentDate!, age: 10) { (result) in
            print(result)
            self.agesCount["10"] = result
            self.setChart()
        }
        
        getVisitorsByDateAndAge(date: currentDate!, age: 20) { (result) in
            print(result)
            self.agesCount["20"] = result
            self.setChart()
        }
        
        getVisitorsByDateAndAge(date: currentDate!, age: 30) { (result) in
            print(result)
            self.agesCount["30"] = result
            self.setChart()
        }
        
        getVisitorsByDateAndAge(date: currentDate!, age: 40) { (result) in
            print(result)
            self.agesCount["40"] = result
            self.setChart()
        }
        
        getVisitorsByDateAndAge(date: currentDate!, age: 50) { (result) in
            print(result)
            self.agesCount["50"] = result
            self.setChart()
        }
        
        getVisitorsByDateAndAge(date: currentDate!, age: 60) { (result) in
            print(result)
            self.agesCount["60"] = result
            self.setChart()
        }
        
        getVisitorsByDateAndAge(date: currentDate!, age: 70) { (result) in
            print(result)
            self.agesCount["70"] = result
            self.setChart()
        }
        
        completion()
        
    }
    
    
    private func getVisitorsByDateAndAge(date: Date, age: Int, finished: @escaping (_ result: Int) -> Void) {
        var visitorsCount = 0
        db.collection("visitors").whereField("date", isEqualTo: date)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if(!(querySnapshot?.isEmpty)!) {
                        for document in querySnapshot!.documents {
                            print("\(document.documentID) => \(document.data())")
                            print(document.data())
                            print(document.data()["age"]!)
                            if(document.data()["age"]! as? Int == age) {
                                  visitorsCount += 1
                            }
                            // [END get_multiple]
                        }
                        finished(visitorsCount)
                    }
                    
                }
        }
        
    }
    
    private func updatePieChart() {
        let legend = pieChart.legend
        legend.enabled = true
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = true
        legend.yOffset = 10.0;
        legend.xOffset = 10.0;
        legend.yEntrySpace = 0.0;
        legend.textColor = UIColor.white;
        let entry1 = PieChartDataEntry(value: Double(self.malesCount), label: "Males")
        let entry2 = PieChartDataEntry(value: Double(self.femalesCount), label: "Females")
        let dataSet = PieChartDataSet(values: [entry1, entry2], label: "")
        pieChart.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        pieChart.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.chartDescription?.text = ""
        dataSet.colors = ChartColorTemplates.joyful()
        pieChart.legend.font = UIFont(name: "Futura", size: 15)!
//        pieChart.chartDescription?.font = UIFont(name: "Futura", size: 12)!
//        pieChart.chartDescription?.xOffset = pieChart.frame.width + 30
//        pieChart.chartDescription?.yOffset = pieChart.frame.height * (2/3)
//        pieChart.chartDescription?.textAlign = NSTextAlignment.left
        //All other additions to this function will go here
//        pieChart.animate(xAxisDuration: 1.4)
//        pieChart.animate(yAxisDuration: 1.4)
        dataSet.valueLinePart1OffsetPercentage = 1
        dataSet.valueLinePart1Length = 0.5
        dataSet.valueLinePart2Length = 0.5
        //set.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.sliceSpace = 2
        let pFormatter = NumberFormatter()
//        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
//        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(.systemFont(ofSize: 11, weight: .bold))
        data.setValueTextColor(.white)
        pieChart.spin(duration: 2,
                       fromAngle: pieChart.rotationAngle,
                       toAngle: pieChart.rotationAngle + 360,
                       easingOption: .easeInCubic)
        //This must stay at end of function
        pieChart.notifyDataSetChanged()
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
 
    private func showAlert(text: String) {
        let alert = UIAlertController(title: "Alert", message: text, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
        } else {
            // Fallback on earlier versions
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
