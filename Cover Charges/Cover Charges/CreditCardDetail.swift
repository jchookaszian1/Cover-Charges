//
//  CreditCardDetail.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 6/28/18.
//  Copyright © 2018 Joe Chookaszian. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class CreditCardDetail: UIViewController {
    var desc:String = ""
    var cardDesc: String = ""
    @IBOutlet weak var cardDescription: UILabel!
    override func viewDidLoad() {
        cardDescription.text = desc
        super.viewDidLoad()
        print(cardDesc)
        // Do any additional setup after loading the view.
    }

    @IBAction func deleteCard(_ sender: Any) {
        let ref = Database.database().reference()
        guard let user = Auth.auth().currentUser else
        {
            print("no user")
            return
        }
        ref.child("stripe_customers").child(user.uid).child("sources").child(cardDesc).removeValue { error, _ in
            if let error = error {
                print(error)
            }
            else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
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
