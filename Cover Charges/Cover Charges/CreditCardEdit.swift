//
//  CreditCardEdit.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 6/25/18.
//  Copyright © 2018 Joe Chookaszian. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class CreditCardEdit: UITableViewController {
    var paymentSources: [String:String] = [:]
    var track: [Int:String] = [:]
    var trackCard: [Int:String] = [:]
    var counter = 0
    var brand = ""
    var cardDesc = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        
        let user = Auth.auth().currentUser
        ref.child("stripe_customers").child((user?.uid)!).child("sources").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                
                let data = child as! DataSnapshot
                let cardNumber = (data.childSnapshot(forPath: "last4").value) as! String
                let brand = (data.childSnapshot(forPath: "brand").value) as! String
                let cardID = (data.childSnapshot(forPath: "id").value) as! String
                let card = cardNumber + "-" + brand
                print(data.key)
                self.paymentSources[cardID] = card
                self.track[self.counter] = cardID
                self.trackCard[self.counter] = data.key
                self.counter = self.counter + 1
            }
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! CreditCardCell
        brand = currentCell.brandNum.text!
        cardDesc = trackCard[indexPath.row]!
        performSegue(withIdentifier: "toCreditCardEdit", sender: self)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return paymentSources.count
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let receiptsNib = UINib(nibName: "CreditCardCell", bundle: nil)
        tableView.register(receiptsNib, forCellReuseIdentifier: "CreditCardCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCardCell", for: indexPath) as? CreditCardCell  else {
            fatalError("The dequeued cell is not an instance of CreditCardSelectionCell.")
        }        // Configure the cell...
        
        let id = track[indexPath.row]
        cell.brandNum.text = paymentSources[id!]
        cell.barID = id!
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "toCreditCardEdit")
        {
            print(type(of: brand))
            let dest = segue.destination as! CreditCardDetail
            dest.desc = brand
            dest.cardDesc = cardDesc
        }
    }
    

}
