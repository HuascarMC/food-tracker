//
//  DataViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 03/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit
import Firebase

class DataViewController: UIViewController {
    @IBOutlet weak var malesCount: UILabel!
    @IBOutlet weak var femalesCount: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    
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
    }
    
    private func getTotalMales() {
        var count = 0
        db.collection("visitors").whereField("gender", isEqualTo: "male").whereField("date", isEqualTo: self.currentDate!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    
                } else {
                        self.showAlert(text: (self.currentDate?.description)!)
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        count += 1
                        // [END get_multiple]
                        self.malesCount.text = count.description
                    }
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
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        count += 1
                        // [END get_multiple]
                        self.femalesCount.text = count.description
                    }
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
