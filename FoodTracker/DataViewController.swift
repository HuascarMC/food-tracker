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
    @IBOutlet weak var malesCount: UILabel!
    @IBOutlet weak var femalesCount: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!
    
    var db: Firestore!
    var currentDate: Date?
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // [START setup]
        let settings = FirestoreSettings()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let date = datePicker.date
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let dateString = dateFormatter.string(from: date as Date)
        self.currentDate = dateFormatter.date(from: dateString)

        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
        self.getTotalMales()
        self.getTotalFemales()
        updatePieChart()
    }
    
    private func getTotalMales() {
        var count = 0
        db.collection("visitors").whereField("gender", isEqualTo: "male").whereField("date", isEqualTo: self.currentDate!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                    if(!(querySnapshot?.isEmpty)!) {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        count += 1
                        // [END get_multiple]
                    }
                }
            self.malesCount.text = count.description
          }
        }
 
    }
    
    private func getTotalFemales() {
        var count = 0
        db.collection("visitors").whereField("gender", isEqualTo: "female").whereField("date", isEqualTo: self.currentDate!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if(!(querySnapshot?.isEmpty)!) {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        count += 1
                        // [END get_multiple]
                        }
                 }
                    self.femalesCount.text = count.description
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
        self.getTotalMales()
        self.getTotalFemales()
        self.updatePieChart()
       
    }
    
    private func updatePieChart() {
            let entry1 = PieChartDataEntry(value: Double(malesCount.text!)!, label: "Males")
        let entry2 = PieChartDataEntry(value: Double(femalesCount.text!)!, label: "Females")
        let dataSet = PieChartDataSet(values: [entry1, entry2], label: "Gender")
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.chartDescription?.text = "By Gender"
        dataSet.colors = ChartColorTemplates.joyful()
        pieChart.legend.font = UIFont(name: "Futura", size: 10)!
        pieChart.chartDescription?.font = UIFont(name: "Futura", size: 12)!
        pieChart.chartDescription?.xOffset = pieChart.frame.width + 30
        pieChart.chartDescription?.yOffset = pieChart.frame.height * (2/3)
        pieChart.chartDescription?.textAlign = NSTextAlignment.left
        //All other additions to this function will go here
        
        //This must stay at end of function
        pieChart.notifyDataSetChanged()
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
