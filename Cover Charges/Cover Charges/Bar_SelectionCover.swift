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
class Bar_SelectionCover: UIViewController, UITableViewDelegate, UITableViewDataSource{
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
        performSegue(withIdentifier: "toTicketCreationCover", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        defaults.set(1, forKey: "firstTimeLogin")
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        var ref: DatabaseReference!
        
        print("on the cover screen")
        ref = Database.database().reference()
        ref.child("stripe_bar_users").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let data = child as! DataSnapshot
                let prefName = data.childSnapshot(forPath: "preferred_name").value as! String
                let barID = data.key
                let isCover = data.childSnapshot(forPath: "cover_charges").value as! Bool
                
                if(isCover)
                {
                    guard let bar = BarStruct(barName: prefName,ID: barID) else {
                        fatalError("Unable to instantiate meal2")
                    }
                    self.bars.append(bar)
                }
            }})
    }
    override func viewDidAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: false)
        }
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toTicketCreationCover")
        {
            let dest = segue.destination as! TicketCreationCover
            dest.barID = valToPass
            dest.barName = barNameToPass
            
        }
    }
    
}

