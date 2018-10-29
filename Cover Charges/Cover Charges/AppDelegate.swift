//
//  AppDelegate.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 8/7/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import Stripe
import ChameleonFramework
import DropDown
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool
    {
        DropDown.startListeningToKeyboard()
        FirebaseApp.configure()
        STPPaymentConfiguration.shared().publishableKey = "pk_test_aPecMv6L6Y0xzmxRxtMFZpVK"
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        return true
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              open: url,
                                                              sourceApplication: sourceApplication,
                                                              annotation: annotation)
        return true
    }
    
    }
