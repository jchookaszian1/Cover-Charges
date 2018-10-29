//
//  ReceiptsList.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 9/11/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class ReceiptsList: UITableViewController {
    var placeToSearch: String = ""
    var receipts = [ReceiptStruct]()
    var valueToPass: ReceiptStruct? = nil
    var isLineSkip: Bool = false
    var menu = [String:Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        var ref: DatabaseReference!
        ref = Database.database().reference()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let user = Auth.auth().currentUser
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        ref.child("stripe_customers").child((user?.uid)!).child("receipts").child(placeToSearch).observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                
                
                let data = child as! DataSnapshot
                let barName = (data.childSnapshot(forPath: "barName").value)! as! String
                self.isLineSkip = (data.childSnapshot(forPath: "isLineSkip").value)! as! Bool
                let date = (data.childSnapshot(forPath: "date").value)! as! Int
                guard let receipt = ReceiptStruct(barName: barName,receiptID: data.key as String, dateID: date) else {
                    fatalError("Unable to instantiate meal2")
                }
                                self.receipts.append(receipt)
                }
        }) { (error) in
            print(error.localizedDescription)
        }
        receipts.reverse()
        self.tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return receipts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let receiptsNib = UINib(nibName: "ReceiptsListCell", bundle: nil)
        tableView.register(receiptsNib, forCellReuseIdentifier: "ReceiptsListCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiptsListCell", for: indexPath) as? ReceiptsListCell  else {
            fatalError("The dequeued cell is not an instance of ReceiptsListCell.")
        }        // Configure the cell...
        
        let receipt = receipts[indexPath.row]
        cell.barName.text = receipt.name
        cell.receiptKey = receipt.key
        let timestampDate = NSDate(timeIntervalSince1970: Double(receipt.date as NSNumber)/1000)
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
        
        let myString = formatter.string(from: timestampDate as Date)
        let yourDate = formatter.date(from: myString)
       
        formatter.dateFormat = "yyyy/MM/dd hh:mm a"
        let myStringafd = formatter.string(from: yourDate!)
        
        cell.dateLabel.text = myStringafd
        cell.ID = receipt
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexPath = tableView.indexPathForSelectedRow!
        let currentCell = tableView.cellForRow(at: indexPath)! as! ReceiptsListCell
        valueToPass = currentCell.ID
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let user = Auth.auth().currentUser
        ref.child("stripe_customers").child((user?.uid)!).child("receipts").child(self.placeToSearch).child(valueToPass!.key).child("menuItems").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children {
                let data = child as! DataSnapshot
                self.menu.updateValue(data.value as! Int, forKey: data.key)
            }
            if(self.isLineSkip)
            {
                self.performSegue(withIdentifier: "displayReceiptLineSkip", sender: self)
            }
            else
            {
                self.performSegue(withIdentifier: "displayReceipt", sender: self)
            }
        }) { (error) in
            let alert = UIAlertController(title: "Error", message: (error.localizedDescription), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                return
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "displayReceipt")
        {
            
                let dest = segue.destination as! Receipt
                let value = valueToPass!
                dest.receiptKey = (value.key)
                dest.barName = (value.name)
                dest.placeToSearch = self.placeToSearch
                print(self.menu.count)
                dest.menu = self.menu
        }
        if(segue.identifier == "displayReceiptLineSkip")
        {
            
            let dest = segue.destination as! Receipt
            let value = valueToPass!
            dest.receiptKey = (value.key)
            dest.barName = (value.name)
            dest.placeToSearch = self.placeToSearch
            print(self.menu.count)
            dest.menu = self.menu
        }

    }
    

}
