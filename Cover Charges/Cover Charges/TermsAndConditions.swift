//
//  TermsAndConditions.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 8/28/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FBSDKLoginKit
class TermsAndConditions: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func agreed(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(Constants.TCVERSION, forKey: "TCVersion")
        if(FBSDKAccessToken.current() != nil)
        {
            performSegue(withIdentifier: "toBarSelectionTC", sender: self)
        }
        else if(defaults.integer(forKey: "firstTimeLogin") == 1)
        {
            performSegue(withIdentifier: "toBarSelectionTC", sender: self)
        }
        else
        {
            performSegue(withIdentifier: "toAccountScreenTC", sender: self)
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
