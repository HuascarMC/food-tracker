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
     
        // Enable the Save button only if the text field has a valid Meal name.
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


