//
//  Bar Selection.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 8/15/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
class AccountSettings: UITableViewController{
    
    
    override func viewDidLoad() {
        self.tableView.tableFooterView = UIView()
    }
    
    @IBAction func deleteAccount(_ sender: Any) {
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                // An error happened.
            } else {
                let loginManager = FBSDKLoginManager()
                loginManager.logOut()
                let firebaseAuth = Auth.auth()
                do {
                    try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                 self.performSegue(withIdentifier: "toRoot", sender: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
}

