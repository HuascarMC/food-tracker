//
//  ViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 27/05/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//
import os.log
import UIKit
import Charts
import Firebase

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var lineChart: LineChartView!
    @IBOutlet weak var BarChart: BarChartView!
    

    
    /*
     This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new meal.
     */
    var meal: Meal?
    var startDate: Date?
    var endDate: Date?
    var malesCount = 10
    var femalesCount = 15
    var db: Firestore!
     let ages = ["0-10", "11-20", "21-30", "31-40", "41-50", "51-60", "61-70"]
    var days = [
        "previousx1" : 7,
        "beforeYesterday" : 3,
        
        "previousx2" : 5,
        "today" : 12,
        "yesterday" : 1
        
    ]
    var agesCount = [
        "10" : 20,
        "20": 25,
        "30" : 10,
        "40" : 15,
        "50" : 5,
        "60" : 40,
        "70" : 35,
        ]
    
    @IBAction func cancel(_ sender: Any) {
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
    }
    //MARK: Navigation
    
    // This method lets you configure a view controller before it's presented.
//    @available(iOS 10.0, *)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            if #available(iOS 10.0, *) {
                os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            } else {
                // Fallback on earlier versions
            }
            return
        }
        
        
        
        let name = labelTextField.text ?? ""
        let photo = photoImageView.image
        let rating = ratingControl.rating
        let startDate = dateConverter(date: startDatePicker.date)
        let endDate = dateConverter(date: endDatePicker.date)
        
        // Set the meal to be passed to MealTableViewController after the unwind segue.
        meal = Meal(name: name, photo: photo, rating: rating, startDate: startDate , endDate: endDate)
    }
    
    private func dateConverter(date: Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let dateString = dateFormatter.string(from: date as Date)
        return dateFormatter.date(from: dateString)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        labelTextField.delegate = self
        
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            labelTextField.text   = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
        }
        // [START setup]
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        // Do any additional setup after loading the view.
        self.updatePieChart()
        self.updateLineChart()
        self.setChart()
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let greatestHue = days.max { a, b in a.value < b.value }
        
        let leftAxis = lineChart.leftAxis
        leftAxis.removeAllLimitLines()
        //        leftAxis.addLimitLine(ll1)
        //        leftAxis.addLimitLine(ll2)
        leftAxis.axisMaximum = Double(((greatestHue?.value)! + 5))
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
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveButton.isEnabled = false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImageFromPhotoUI(_ sender: Any) {
        // Hide keyboard.
        labelTextField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = labelTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    

    
//    private func getVisitorsByDateRangeAndGender(startDate: Date, endDate: Date, finished: @escaping (_ result: Int) -> Void) {
//        var visitorsCount = 0
//        db.collection("visitors").whereField("date", isLessThan: startDate).getDocuments() { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                } else {
//                    if(!(querySnapshot?.isEmpty)!) {
//                        for document in querySnapshot!.documents {
//                            print("\(document.documentID) => \(document.data())")
//                            print(document.data())
//                            print(document.data()["age"]!)
////                            if(document.data()["gender"]! as? String == "male") {
////                                self.malesCount += 1
////                            } else {
////                                self.femalesCount += 1
////                            }
//                            visitorsCount += 1// [END get_multiple]
//                        }
//                        finished(visitorsCount)
//                    }
//
//                }
//        }
//        print(visitorsCount)
//    }
}


