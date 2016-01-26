//
//  ViewController.swift
//  showcase
//
//  Created by shengxiang guo on 1/25/16.
//  Copyright © 2016 shengxiang guo. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.didReceiveMemoryWarning()
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil)
        }
    }
    @IBAction func fbButtonPressed(sender: UIButton!){
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            if facebookError != nil {
                print("Facebook login failed. \(facebookError)")
            }else {
                let accessTocken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully loged in with Facebook. \(accessTocken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessTocken, withCompletionBlock: { error, authData in
                    if error != nil{
                        print("Login failed.\(error)")
                    }else{
                        print("Loggined In! \(authData)")
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil)
                    }
                })
            }
        }
    }
    @IBAction func attemptLogin(sender: UIButton!){
        if let email = emailField.text where email != "", let pwd = PasswordField.text where pwd != ""{
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: {err,authData in
                if err != nil {
                    print(err.code)
                    print(err)
                    if err.code == STATUS_ACCOUNT_NONEXIST{
                       DataService.ds.REF_BASE.createUser(email, password: pwd, withValueCompletionBlock: { error, result in
                        if error != nil{
                            self.showErrorAlert("could not create account", msg: "Problem creating account, try something else")
                        }else {
                            NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: nil)
                            self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil)
                        }
                       })
                    }else{
                        self.showErrorAlert("Could not log in", msg:" please check your username or password" )
                    }
                }else {
                    self.performSegueWithIdentifier(SEGUE_LOGGEDIN, sender: nil)
                }
            })
        }else{
            showErrorAlert("Email and Password Required", msg: "You must enter an email and password")
        }
    }
    
    func showErrorAlert(title: String, msg: String){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}

