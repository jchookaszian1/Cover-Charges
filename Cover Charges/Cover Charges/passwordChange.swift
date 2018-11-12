//
//  EmailChange.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 5/15/18.
//  Copyright © 2018 Joe Chookaszian. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class passwordChange: UIViewController {
    
    @IBOutlet weak var passwordSubmit: UIButton!
    @IBOutlet weak var noMatch: UILabel!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(self.didTapView))
        // Do any additional setup after loading the view.
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Focus on the field
    @IBAction func editingDidEnd(_ sender: Any) {
        let whitespace = NSCharacterSet.whitespaces
        if(passwordText.text?.trimmingCharacters(in: whitespace) == ""){
            errorHighlightTextField(textField: passwordText)
        }
        else{
            removeErrorHighlightTextField(textField: passwordText)
        }
    }
    @IBAction func emailTouchDown(_ sender: Any) {
        highlightSelectedTextField(textfield: passwordText)
    }
    @IBAction func checkEmails(_ sender: Any) {
        if(!(passwordText.text == confirmPassword.text))
        {
            errorHighlightTextField(textField: passwordText)
            noMatch.isHidden = false
        }
        else{
            removeErrorHighlightTextField(textField: passwordText)
            noMatch.isHidden = true
        }
        
    }
    
    // When editing ends...
    
    // When focussed - show gray border
    func highlightSelectedTextField(textfield: UITextField){
        textfield.layer.borderColor = UIColor.gray.cgColor
        textfield.layer.borderWidth = 1
        textfield.layer.cornerRadius = 5
    }
    
    // Text Field is empty - show red border
    func errorHighlightTextField(textField: UITextField){
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 5
    }
    
    // Text Field is NOT empty - show gray border with 0 border width
    func removeErrorHighlightTextField(textField: UITextField){
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 0
        textField.layer.cornerRadius = 5
    }
    @objc func didTapView(){
        self.view.endEditing(true)
    }
    @IBAction func submitPassword(_ sender: Any) {
        Auth.auth().currentUser?.updatePassword(to: passwordText.text!) { (error) in
            // ...
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

