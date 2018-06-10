//
//  SignViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 10/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit
import FirebaseUI

class SignViewController: UIViewController {
    fileprivate(set) var auth:Auth?
    fileprivate(set) var authUI: FUIAuth? //only set internally but get externally
    fileprivate(set) var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "myVC") as UIViewController
            self.present(initViewController, animated: true, completion: nil)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try Auth.auth().signOut() }
        catch {
          
        }
        // Do any additional setup after loading the view, typically from a nib.
        self.auth = Auth.auth()
        self.authUI = FUIAuth.defaultAuthUI()
        self.authUI?.delegate = self as? FUIAuthDelegate
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            ]
        self.authUI?.providers = providers
        
        self.authStateListenerHandle = self.auth?.addStateDidChangeListener { (auth, user) in
            guard user != nil else {
                self.loginAction(sender: self)
      
                return
            }
        }
        // Do any additional setup after loading the view.
    }
    
    

    @IBAction func loginAction(sender: AnyObject) {
        // Present the default login view controller provided by authUI
        let authViewController = authUI?.authViewController();
        self.present(authViewController!, animated: true, completion: nil)

    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        guard let authError = error else { return }
        
        let errorCode = UInt((authError as NSError).code)
        
        switch errorCode {
        case FUIAuthErrorCode.userCancelledSignIn.rawValue:
            print("User cancelled sign-in");
            break
            
        default:
            let detailedError = (authError as NSError).userInfo[NSUnderlyingErrorKey] ?? authError
            print("Login error: \((detailedError as! NSError).localizedDescription)");
        }
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "myVC") as! MainViewController
        self.present(initViewController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
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
