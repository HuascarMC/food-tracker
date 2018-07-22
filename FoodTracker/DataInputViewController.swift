//
//  DataInputViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 22/07/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit
import Firebase
import TTGSnackbar

class DataInputViewController: UIViewController {
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var toTenMale: UIButton!
    @IBOutlet weak var toTwentyMale: UIButton!
    @IBOutlet weak var toThirtyMale: UIButton!
    @IBOutlet weak var toFortyMale: UIButton!
    @IBOutlet weak var toFiftyMale: UIButton!
    @IBOutlet weak var toSixtyMale: UIButton!
    @IBOutlet weak var toSeventyMale: UIButton!
    @IBOutlet weak var toTenFemale: UIButton!
    @IBOutlet weak var toTwentyFemale: UIButton!
    @IBOutlet weak var toThirtyFemale: UIButton!
    @IBOutlet weak var toFortyFemale: UIButton!
    @IBOutlet weak var toFiftyFemale: UIButton!
    @IBOutlet weak var toSixtyFemale: UIButton!
    @IBOutlet weak var toSeventyFemale: UIButton!
    
    var currentData: Date?
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let date = NSDate()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        let dateString = dateFormatter.string(from: date as Date)
        self.currentDate = dateFromatter.date(from: dateString)
    
        dateFormatter.locale = Locale(identifier: "en_US")
        let dateStringUS = daterFormatter.string(from: date as Date)
        self.date.text = dateStringUS
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//
//    private func inputButtonPressed(_ button: UIButton) {
//        switch(button.currentTitle) {
//
//        }
//    }
    
    private func addVisitor(gender: String, age: String, date: Date) {
        var ref: DocumentReference? = nil
        ref = db.collection("visitors").addDocument(data: [
            "gender": gender,
            "age": age,
            "date": date
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                self.showAlert(text: "Error")
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.showAlert(text: "Saved")
            }
        }
        // [END add_ada_lovelace]
    }
    
    private func showAlert(text: String) {
        let snackbar = TTGSnackbar(message: text, duration: .short)
        snackbar.show()
        //    let alert = UIAlertController(title: "Alert", message: text, preferredStyle: .alert)
        //    self.present(alert, animated: true, completion: nil)
        //    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { _ in alert.dismiss(animated: true, completion: nil)} )
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
