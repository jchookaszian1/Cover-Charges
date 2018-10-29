//
//  SignUp.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 9/23/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FirebaseAuth
class SignUp: UIViewController {
    
    @IBOutlet weak var backB: UINavigationItem!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var submit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        submit.layer.cornerRadius = 4
        let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: self, action: #selector(back))
        self.backB.leftBarButtonItem = backButton
        // Do any additional setup after loading the view.
    }
    
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func signUp(_ sender: Any) {
        
            Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: {
                (user,error) in
                if(error != nil)
                {
                    let alert = UIAlertController(title: "Error", message: (error?.localizedDescription)!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        return
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                else
                {
                    print("Successfully signed into Firebase 1")
                    self.performSegue(withIdentifier: "unwindToLogin", sender: nil)
                }
            }
            )
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


