//
//  TabBar.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 3/12/18.
//  Copyright © 2018 Joe Chookaszian. All rights reserved.
//

import UIKit
import SideMenu
class TabBar: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers?.forEach { $0.view }
        let logo = UIImage(named: "Flinck Logo Cropped 50.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func moveToMenu(_ sender: UIBarButtonItem) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)

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
