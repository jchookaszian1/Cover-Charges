//
//  TicketCreation.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 1/2/18.
//  Copyright © 2018 Joe Chookaszian. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
class TicketCreationCover: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var totalLabel: UILabel!
    var tickets = [TicketStruct]()
    var barID: String = ""
    var barName: String = ""
    var finalMenu = [String:Int]()
    var total: Int = 0
    var pickerData: Set<String> = Set<String>()
    var track: Dictionary<Int,String> = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let rightButtonItem = UIBarButtonItem.init(
            title: "Clear All",
            style: .done,
            target: self,
            action: #selector(clearAll(sender:))
        )
        self.navigationItem.rightBarButtonItem = rightButtonItem
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        let user = Auth.auth().currentUser
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        var initialTotal = 0
        ref.child("stripe_bar_pricing").child(barID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            
            let data = snapshot as! DataSnapshot
            var itemName = "Cover Charges"
            //print(data.key)
            var price = (data.childSnapshot(forPath: "cover_price").value) as! String
            var defaults = UserDefaults.standard
            var amount = String(defaults.integer(forKey: itemName))
            
            initialTotal = initialTotal + defaults.integer(forKey: itemName) * Int(price)!
            if(defaults.object(forKey: itemName) != nil)
            {
                
                amount = String(defaults.integer(forKey: itemName))
                
            }
            guard var ticket = TicketStruct(itemName: itemName,price: price,amountID: amount) else {
                fatalError("Unable to instantiate meal2")
            }
            self.tickets.append(ticket)
            
            self.totalLabel.text = "$"+String(initialTotal)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    @objc func clearAll(sender: UIBarButtonItem)
    {
        for item in tickets {
            let defaults = UserDefaults.standard
            defaults.set(0, forKey: item.name)
        }
        self.totalLabel.text = "$"+String(0)
        self.tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tickets.count
    }
    
    @IBAction func proceedToCheckout(_ sender: Any) {
        let numRows = tableView.numberOfRows(inSection: 0)
        for index in 0...numRows-1
        {
            let path = IndexPath.init(row: index, section: 0)
            let cell = tableView.cellForRow(at: path) as! TicketsCreationCell
            let name = cell.itemName.text
            let amount = cell.amount.text
            let amountNum = Int(amount!)!
            if(amountNum != 0)
            {
                finalMenu.updateValue(amountNum, forKey: name!)
            }
        }
        var totalWithoutDollar = totalLabel.text!
        totalWithoutDollar = totalWithoutDollar.replacingOccurrences(of: "$", with: "")
        total = Int(totalWithoutDollar)!
        if(total == 0)
        {
            let alert = UIAlertController(title: "Error", message: "Must select at least 1 item", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                return
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
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
                self.track.updateValue((cardID), forKey: self.track.count)
                self.pickerData.insert(card)
            }
            self.performSegue(withIdentifier: "toPaymentScreen", sender: self)
        })
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let receiptsNib = UINib(nibName: "TicketsCreationCell", bundle: nil)
        tableView.register(receiptsNib, forCellReuseIdentifier: "TicketsCreationCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TicketsCreationCell", for: indexPath) as? TicketsCreationCell  else {
            fatalError("The dequeued cell is not an instance of TicketsCreationCell.")
        }        // Configure the cell...
        let ticket = tickets[indexPath.row]
        let priceCell = "$" + ticket.key
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.itemName.text = ticket.name
        cell.price.text = priceCell
        let defaults = UserDefaults.standard
        
        cell.amount.text = String(defaults.integer(forKey: ticket.name))
        cell.counter.value = Double(defaults.integer(forKey: ticket.name))
        cell.lastValue = defaults.integer(forKey: ticket.name)
        cell.totalLabel = totalLabel
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "toPaymentScreen")
        {
            let dest = segue.destination as! PaymentScreen
            dest.barID = barID
            dest.value = String(total)
            dest.pickerData = pickerData
            dest.track = track
            dest.menuPass = finalMenu
            dest.barName = barName
        }
        
        
    }
}


//////////////////////////////////////////////////








