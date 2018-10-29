//
//  Receipt.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 9/11/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
class Receipt: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var usedReceipt: UIImageView!
    @IBOutlet weak var barNameLabel: UILabel!
    var barName:String = ""
    var placeToSearch = "wallet"
    var receiptKey:String = ""
    var isLineSkip:Bool = false
    var menu = [String:Int]()
    var menuItems = [MenuStruct]()
    var date:[String : Any] = ServerValue.timestamp() as! [String : Any]
    
    @IBOutlet weak var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let receiptsNib = UINib(nibName: "MenuListCell", bundle: nil)
        tableView.register(receiptsNib, forCellReuseIdentifier: "MenuListCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MenuListCell", for: indexPath) as? MenuListCell  else {
            fatalError("The dequeued cell is not an instance of MenuListCell.")
        }        // Configure the cell...
        let menuItem = menuItems[indexPath.row]
        cell.amountLabel.text = menuItem.amount
        cell.itemNameLabel.text = menuItem.name
        return cell
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        passButton.layer.cornerRadius = 4
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.backToInitial(sender:)))
        let user = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database().reference()
        self.title = barName
        ref.child("stripe_customers").child((user?.uid)!).child("receipts").child(placeToSearch).child(receiptKey).observeSingleEvent(of: .value, with: { (snapshot) in
            let data = (snapshot.childSnapshot(forPath: "isExpired")).value as! Bool
            self.isLineSkip = (snapshot.childSnapshot(forPath: "isLineSkip")).value as! Bool
            if(data == true)
            {
                self.usedReceipt.isHidden = false
            }
        }) { (error) in
            let alert = UIAlertController(title: "Error", message: (error.localizedDescription), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                return
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        for item in menu
        {
            let input = MenuStruct(itemName: item.key, amountInput: String(item.value))
            menuItems.append(input!)
        }
        self.tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    @objc func backToInitial(sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    @IBAction func usePass(_ sender: Any) {
        let user = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref = ref.child("stripe_customers").child((user?.uid)!).child("receipts").child(placeToSearch).child(receiptKey)
        ref.setValue(["isExpired": true, "barName": barName, "isLineSkip": isLineSkip, "date" : date],withCompletionBlock: {(error, refActual) in
            if(error != nil)
            {
                let alert = UIAlertController(title: "Error", message: (error?.localizedDescription)!, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                    return
                    
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else
            {

                var refReceipt: DatabaseReference!
                refReceipt = Database.database().reference()
                refReceipt = refReceipt.child("stripe_customers").child((user?.uid)!).child("receipts").child("history")
                self.usedReceipt.isHidden = false
                self.indicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                    refReceipt.observe(DataEventType.value, with: { (snapshot) in
                        print("in the observeR")
                        print(snapshot.key)
                        if snapshot.hasChild(self.receiptKey) {
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                            refReceipt.removeAllObservers()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                }
            }
            
        })


        
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
