//
//  PaymentInfo.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 8/8/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Stripe
import FirebaseDatabase
import FirebaseAuth
class AccountScreen: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var submitCard: UIButton!
    @IBOutlet weak var expDate: UITextField!
    @IBOutlet weak var CCV: UITextField!
    @IBOutlet weak var zipCode: UITextField!
    @IBOutlet weak var cardNumber: UITextField!
    var indicator = UIActivityIndicatorView()
    
    @IBAction func addCreditCard(_ sender: Any) {
        let user = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let StripeCard = STPCardParams()
        let cardNumber = (self.cardNumber.text)!.replacingOccurrences(of: "-", with: "")
        StripeCard.number = cardNumber
        StripeCard.cvc = CCV.text
        StripeCard.address.postalCode = zipCode.text
        let expDate = self.expDate.text
        let date = expDate?.components(separatedBy: "/")
        StripeCard.expMonth = UInt((date?[0])!)!
        StripeCard.expYear = UInt((date?[1])!)!;
        STPAPIClient.shared().createToken(withCard: StripeCard, completion: { (token, error) -> Void in
            
            if error != nil {
                print(error!)
                return
            }
            let refSources = ref.child("stripe_customers").child((user?.uid)!).child("sources")
            let key = refSources.childByAutoId().key
            let refActual = ref.child("stripe_customers").child((user?.uid)!).child("sources").child(key!).child("token")
            let refCard = ref.child("stripe_customers").child((user?.uid)!).child("sources").child(key!)
            refActual.setValue(token?.tokenId, withCompletionBlock: { (error, refActual) in
                if(error != nil)
                {
                    print(error!.localizedDescription)
                    return
                }
                else
                {
                    self.indicator.startAnimating()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                        refCard.observe(DataEventType.value, with: { (snapshot) in
                            if snapshot.hasChild("last4") {
                                self.indicator.stopAnimating()
                                self.indicator.hidesWhenStopped = true
                                refCard.removeAllObservers()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                self.performSegue(withIdentifier: "toBarSelection", sender: nil)
                            }
                        })
                    }
                }
            })
        })
    }
    @IBAction func Skip(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toBarSelection", sender: nil)
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator()
        submitCard.layer.cornerRadius = 4
        if(self.restorationIdentifier == "accountScreen")
        {
            skipButton.layer.cornerRadius = 4
        }
        // Do any additional setup after loading the view.
        self.expDate.delegate = self
        self.CCV.delegate = self
        self.zipCode.delegate = self
        self.cardNumber.delegate = self
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(self.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    func activityIndicator() {
        indicator = UIActivityIndicatorView.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.view.center
        indicator.layer.cornerRadius = 10
        indicator.backgroundColor = UIColor.flatBlue
        self.view.addSubview(indicator)
        indicator.bringSubviewToFront(self.view)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if(textField == expDate)
        {
            //Range.Lenth will greater than 0 if user is deleting text - Allow it to replce
            if range.length > 0
            {
                return true
            }
            
            //Dont allow empty strings
            if string == " "
            {
                return false
            }
            
            //Check for max length including the spacers we added
            if range.location >= 5
            {
                return false
            }
            
            var originalText = textField.text
            
            //Put / space after 2 digit
            if range.location == 2
            {
                originalText?.append("/")
                textField.text = originalText
            }
            
        }
        if(textField == cardNumber)
        {
            let str = textField.text! + string
            
            let stringWithoutSpace = str.replacingOccurrences(of: "-", with: "")
            
            if stringWithoutSpace.characters.count % 4 == 0 && (range.location == textField.text?.characters.count)
            {
                if stringWithoutSpace.characters.count != 16
                {
                    textField.text = str+"-"    // add dash after every 4 characters
                }
                else
                {
                    textField.text = str       // space should not be appended with last digit
                }
                
                return false
            }
            else if str.characters.count > 19
            {
                return false
            }
        }
        return true
    }
    
    @objc func didTapView(){
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
