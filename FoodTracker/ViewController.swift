//
//  ViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 27/05/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        labelTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        labelText.text = labelTextField.text
    }
 
    @IBAction func setLabelName(_ sender: UIButton) {
        labelText.text = "Default text"
    }
    
    @IBAction func selectImageFromPhotoUI(_ sender: Any) {
    }
}

