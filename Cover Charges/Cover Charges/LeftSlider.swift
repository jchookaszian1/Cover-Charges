//
//  LeftSlider.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 8/28/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import ChameleonFramework
import SideMenu
class LeftSlider: UITableViewController {

    @IBOutlet weak var signOut: UIButton!
    @IBOutlet weak var accountSettingsButton: UIButton!
    @IBOutlet weak var addPaymentButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var coverChargeButton: UIButton!
    @IBOutlet weak var walletButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        signOut.backgroundColor = nil
        accountSettingsButton.backgroundColor = nil
        addPaymentButton.backgroundColor = nil
        historyButton.backgroundColor = nil
        drinkButton.backgroundColor = nil
        coverChargeButton.backgroundColor = nil
        walletButton.backgroundColor = nil
        //let layer = CAGradientLayer()
        //layer.frame = self.view.frame
        //layer.colors = [UIColor.flatBlackDark.cgColor, UIColor.flatBlack.cgColor]
        //gradient.layer.insertSublayer(layer, at: 0)
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func toDrinkScreen(_ sender: Any) {
        let drinkScreen = storyboard!.instantiateViewController(withIdentifier: "Main") as! UIViewController
        SideMenuManager.default.menuLeftNavigationController?.pushViewController(drinkScreen, animated: true)
        //performSegue(withIdentifier: "toDrinks", sender: self)
        
    }
    @IBAction func logoutButton(_ sender: Any) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        performSegue(withIdentifier: "unwindToLogin", sender: self)
        
    }
    @IBAction func toWalletPage(_ sender: Any) {
        performSegue(withIdentifier: "toWallet", sender: self)
    }
    @IBAction func toReceiptsPage(_ sender: Any) {
        performSegue(withIdentifier: "toReceipts", sender: self)
    }
    @IBAction func toAccountScreen(_ sender: Any) {
        performSegue(withIdentifier: "addPayment", sender: self)
    }
    @IBAction func toAccountSettingScreen(_ sender: Any) {
        performSegue(withIdentifier: "toAccountSettings", sender: self)
    }
    @IBAction func toCoverScreen(_ sender: Any) {
        //YESSSS
        let coverScreen = storyboard!.instantiateViewController(withIdentifier: "coverScreen") as! TabBar
        SideMenuManager.default.menuLeftNavigationController?.pushViewController(coverScreen, animated: true)
        //performSegue(withIdentifier: "toCover", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "toReceipts")
        {
            let dest = segue.destination as! ReceiptsList
            dest.placeToSearch = "history"
        }
        else if(segue.identifier == "toWallet")
        {
            let dest = segue.destination as! ReceiptsList
            dest.placeToSearch = "wallet"
        }
    }
    

}
