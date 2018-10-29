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
import SideMenu
class Bar_Selection: UIViewController, UITableViewDelegate, UITableViewDataSource{
    var bars = [BarStruct]()
    var valToPass: String = ""
    var barNameToPass: String = ""
    @IBOutlet weak var tableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let receiptsNib = UINib(nibName: "BarSelectionCell", bundle: nil)
        tableView.register(receiptsNib, forCellReuseIdentifier: "BarSelectionCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BarSelectionCell", for: indexPath) as? BarSelectionCell  else {
            fatalError("The dequeued cell is not an instance of BarSelectionCell.")
        }        // Configure the cell...
        
        let bar = bars[indexPath.row]
        cell.backgroundColor = UIColor.flatBlackDark
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.barName.textColor = UIColor.flatMintDark
        cell.barName.text = bar.name
        cell.barID = bar.key
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! BarSelectionCell
        valToPass = currentCell.barID
        barNameToPass = currentCell.barName.text!
        performSegue(withIdentifier: "toTicketCreation", sender: self)
    }
    
    @IBAction func moveToMenu(_ sender: UIBarButtonItem) {
        present(SideMenuManager.default.menuLeftNavigationController!, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        print("view will appear")
        let defaults = UserDefaults.standard
        defaults.set(1, forKey: "firstTimeLogin")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        let logo = UIImage(named: "Flinck Logo Cropped 50.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        print("view did load")
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        ref.child("stripe_bar_users").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let data = child as! DataSnapshot
                let prefName = data.childSnapshot(forPath: "preferred_name").value as! String
                let barID = data.key
                let isDrink = data.childSnapshot(forPath: "drinks").value as! Bool
                
                if(isDrink)
                {
                guard let bar = BarStruct(barName: prefName,ID: barID) else {
                    fatalError("Unable to instantiate meal2")
                }
                self.bars.append(bar)
                }
                print("on the drinks screen")
            }
            self.tableView.reloadData()
            print(self.bars.count)
            //UIView.transition(with: self.tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        })
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toTicketCreation")
        {
            let dest = segue.destination as! TicketCreation
            dest.barID = valToPass
            dest.barName = barNameToPass
        
        }
    }

}
