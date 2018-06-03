//
//  VisitorInputViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 03/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit

class VisitorInputViewController: UIViewController {
    @IBOutlet weak var Male: UIButton!
    @IBOutlet weak var Female: UIButton!
    @IBOutlet weak var Add: UIButton!
    @IBOutlet weak var one: UIButton!
    @IBOutlet weak var two: UIButton!
    @IBOutlet weak var three: UIButton!
    @IBOutlet weak var four: UIButton!
    @IBOutlet weak var five: UIButton!
    @IBOutlet weak var six: UIButton!
    @IBOutlet weak var seven: UIButton!
    
    var ages: Array<UIButton>?
    var genders: Array<UIButton>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.genders = [self.Male, self.Female]
        self.ages = [self.one, self.two, self.three, self.four, self.five, self.six, self.seven]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func ageTapped(_ sender: UIButton) {
        for button in self.ages! {
            button.titleLabel?.textColor = UIColor.gray
        }
    }
    
    @IBAction func genderTapped(_ sender: Any) {
        for button in self.genders! {
           button.titleLabel?.textColor = UIColor.gray
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
