//
//  SignViewController.swift
//  FoodTracker
//
//  Created by Huascar  Montero on 10/06/2018.
//  Copyright © 2018 Huascar  Montero. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase

class LoginViewController: UIViewController {
    fileprivate(set) var auth:Auth?
    fileprivate(set) var authUI: FUIAuth? //only set internally but get externally
    fileprivate(set) var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    var handle: AuthStateDidChangeListenerHandle?
    var db: Firestore!
    var userStats: DocumentReference? = nil
    var currentUserStats = true

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "myVC") as UIViewController
            self.present(initViewController, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        userStats = db.collection("users").document("user")
 

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
        if currentUserStats == true {
            self.authStateListenerHandle = self.auth?.addStateDidChangeListener { (auth, user) in
                guard user != nil else {
                    self.loginAction(sender: self)
                    return
                }
            }
        }
//        getCurrentUserStatus { () in
//            self.triggerAuth()
//
//        }
//


    }
    
    private func triggerAuth() {
        print(currentUserStats)
         print(currentUserStats)
         print(currentUserStats)
         print(currentUserStats)
         print(currentUserStats)
         print(currentUserStats)
         print(currentUserStats)
        if currentUserStats == false {
            self.authStateListenerHandle = self.auth?.addStateDidChangeListener { (auth, user) in
                guard user != nil else {
                    self.loginAction(sender: self)
                    return
                }
            }
        }
    }
    
    

    @IBAction func loginAction(sender: AnyObject) {
//        // Present the default login view controller provided by authUI
//        let authViewController = authUI?.authViewController();
//        let width = 300
//        let height = 300
//        let imageViewBackground = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//        imageViewBackground.image = UIImage(named: "male-symbol")
//        // you can change the content mode:
//        imageViewBackground.center.y = 400
//        imageViewBackground.center.x = 450
//        imageViewBackground.contentMode = UIViewContentMode.scaleAspectFit
//        authViewController?.view.insertSubview(imageViewBackground, at: 1)
//        self.present(authViewController!, animated: true, completion: nil)

            let authViewController = CustomizeAuthViewController(authUI: authUI!)
            let navc = UINavigationController(rootViewController: authViewController)
            self.present(navc, animated: true, completion: nil)


    }
    
    private func getCurrentUserStatus(finished: @escaping () -> Void) {
        userStats?.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                self.currentUserStats = (document.data()!["status"]! as? Bool)!
                   finished()
                print("Document data: \(dataDescription)")
            } else {
                print("Document does not exist")
            }
        }
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
            changeUserStatus(changeStatus: true)
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let initViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "myVC") as! MainViewController
            self.present(initViewController, animated: true, completion: nil)
    }
    
    private func changeUserStatus(changeStatus: Bool) {
        userStats?.setData([
            "status": changeStatus
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
//                self.showAlert(text: "Error")
            } else {
//                print("Document added with ID: \(ref!.documentID)")
//                self.showAlert(text: "Success")
            }
        }
        // [END add_ada_lovelace]
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
