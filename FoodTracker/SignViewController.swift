//
//  SignViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 10/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit
import GoogleSignIn

class SignViewController: UIViewController {
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBAction func signOutClicked(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
