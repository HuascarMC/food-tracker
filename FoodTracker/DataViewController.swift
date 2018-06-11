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
  
    @IBOutlet weak var malesCountLabel: UILabel!
    @IBOutlet weak var femalesCountLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    
    var db: Firestore!
    var currentDate: Date?
    let dateFormatter = DateFormatter()
    var totalVisitors: Double?
    var malesCount = Double(0) {
        didSet {
            self.updatePieChart()
        }
    }
    var femalesCount = Double(0) {
        didSet {
            self.updatePieChart()
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updatePieChart()
     
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
                self.malesCountLabel.text = String(self.malesCount)
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
                    self.femalesCountLabel.text = String(self.femalesCount)
                }
        }
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func search(_ sender: Any) {
        let dateString = dateFormatter.string(from: datePicker.date as Date)
        self.currentDate = dateFormatter.date(from: dateString)
        self.getTotals()
    }
    
    private func updatePieChart() {
        let entry1 = PieChartDataEntry(value: Double(self.malesCount), label: "Males")
        let entry2 = PieChartDataEntry(value: Double(self.femalesCount), label: "Females")
        let dataSet = PieChartDataSet(values: [entry1, entry2], label: "Gender")
        pieChart.setExtraOffsets(left: 20, top: 0, right: 20, bottom: 0)
        pieChart.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.chartDescription?.text = ""
        dataSet.colors = ChartColorTemplates.joyful()
        pieChart.legend.font = UIFont(name: "Futura", size: 10)!
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
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
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
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
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
