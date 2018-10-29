//
//  ViewController.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 8/7/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import SideMenu
class ViewController: UIViewController {
    let defaults = UserDefaults.standard
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var signIn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        let menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "menu") as! UISideMenuNavigationController
        SideMenuManager.default.menuLeftNavigationController = menuLeftNavigationController
        SideMenuManager.default.menuPushStyle = .preserve
        SideMenuManager.default.menuPresentMode = .menuDissolveIn
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(self.didTapView))
        signIn.layer.cornerRadius = 4
        signUp.layer.cornerRadius = 4
        let maskLayer = CAGradientLayer()
        maskLayer.frame = self.view.bounds
        maskLayer.shadowRadius = 9
        maskLayer.shadowPath = CGPath(roundedRect: self.view.bounds.insetBy(dx: 5, dy: 5), cornerWidth: 10, cornerHeight: 10, transform: nil)
        maskLayer.shadowOpacity = 1;
        maskLayer.shadowOffset = CGSize.zero;
        maskLayer.shadowColor = UIColor.darkGray.cgColor
        imageView.layer.mask = maskLayer;
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email"]
        let screenSize:CGRect = UIScreen.main.bounds
        let screenHeight = screenSize.height //real screen height
        //let's suppose we want to have 10 points bottom margin
        loginButton.frame = CGRect(x: 10, y: 10, width: self.view.bounds.size.width - 100, height: 55)
        let newCenterY = screenHeight - loginButton.frame.height - 30
        let newCenter = CGPoint(x:view.center.x, y: newCenterY)
        loginButton.center = newCenter
        
    }
    @IBAction func signIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            if error != nil
            {
                let alert = UIAlertController(title: "Error", message: (error?.localizedDescription)!, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    return
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {
                if(self.defaults.integer(forKey: "TCVersion") == Constants.TCVERSION)
                {
                    if(self.defaults.integer(forKey: "firstTimeLogin") == 1)
                    {
                        self.email.text = ""
                        self.password.text = ""
                        print("Successfully signed into Firebase 4")
                        self.performSegue(withIdentifier: "skipAccountScreen", sender: nil)
                    }
                    else
                    {
                        self.email.text = ""
                        self.password.text = ""
                        print("Successfully signed into Firebase 5")
                        self.performSegue(withIdentifier: "toAccount", sender: nil)
                    }
                }
                else
                {
                    self.email.text = ""
                    self.password.text = ""
                    print("Successfully signed into Firebase 6")
                    self.performSegue(withIdentifier: "toTermsConditions", sender: nil)
                }
            }
            
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if Auth.auth().currentUser != nil {
            // segue to main view controller
            performSegue(withIdentifier: "skipAccountScreen", sender: self)
        } else {
            // sign in
        
        if(FBSDKAccessToken.current() != nil)
        {
            if(defaults.integer(forKey: "TCVersion") == Constants.TCVERSION)
            {
                let accessToken = FBSDKAccessToken.current()
                
                let credentials = FacebookAuthProvider.credential(withAccessToken: (accessToken?.tokenString)!)
                Auth.auth().signIn(with: credentials, completion: {
                    (user, error) in
                    if error != nil
                    {
                        let alert = UIAlertController(title: "Error", message: (error?.localizedDescription)!, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                            return
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    print("Successfully signed into Firebase 1")
                    self.performSegue(withIdentifier: "skipAccountScreen", sender: self)
                })
                
            }
            else
            {
                let accessToken = FBSDKAccessToken.current()
                
                let credentials = FacebookAuthProvider.credential(withAccessToken: (accessToken?.tokenString)!)
                Auth.auth().signIn(with: credentials, completion: {
                    (user, error) in
                    if error != nil
                    {
                        let alert = UIAlertController(title: "Error", message: (error?.localizedDescription)!, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                            return
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    
                    print("Successfully signed into Firebase 2")
                    self.performSegue(withIdentifier: "toTermsConditions", sender: self)
                })
                
            }
        }
        }
    }
    
@IBAction func unwindToRoot(segue:UIStoryboardSegue) { }

}

extension ViewController: FBSDKLoginButtonDelegate
{
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print("Login failed with error: \(error)")
        }
//        else {
//
//            let accessToken = FBSDKAccessToken.current()
//
//            let credentials = FacebookAuthProvider.credential(withAccessToken: (accessToken?.tokenString)!)
//            Auth.auth().signIn(with: credentials, completion: {
//                (user, error) in
//                if error != nil
//                {
//                    let alert = UIAlertController(title: "Error", message: (error?.localizedDescription)!, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
//                        return
//
//                    }))
//                    self.present(alert, animated: true, completion: nil)
//                    return
//                }
//
//                print("Successfully signed into Firebase 3")
//            })
//            if(defaults.integer(forKey: "TCVersion") == Constants.TCVERSION)
//            {
//
//                performSegue(withIdentifier: "toAccount", sender: nil)
//            }
//            else
//            {
//                performSegue(withIdentifier: "toTermsConditions", sender: nil)
//            }
//        }
        
    }
    @objc func didTapView(){
        self.view.endEditing(true)
    }
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
            }
}
