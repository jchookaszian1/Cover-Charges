
//
//  PaymentScreen.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 8/16/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import DropDown
import Firebase
class PaymentScreen: UIViewController  {
    
    
    @IBOutlet weak var picker: UIButton!
    @IBOutlet weak var barValue: UILabel!
    var barID: String = ""
    var barName: String = ""
    var pickerData: Set<String> = Set<String>()
    var track: Dictionary<Int,String> = [:]
    var value:String = ""    // Price displayed/paid
    var receiptKey = ""
    var isLineSkip = false
    var menuPass = [String:Int]()
    var prefName: String = ""
    var date: [String : Any] = ServerValue.timestamp() as! [String : Any]
    @IBOutlet weak var Pay: UIButton!
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Pay.layer.cornerRadius = 4
        var tempVal = Double(value)!
        tempVal = (((tempVal*1.0875)+0.3)/(1-0.029))*1.02
        let finalVal = round(1000.0 * tempVal) / 1000.0
        let currency: String = formatAmount(number: NSNumber(value: Double(finalVal)))
        barValue.text = currency
        DropDown.setupDefaultAppearance()
        dropDown.width = 164
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.picker.setTitle(item, for: .normal)
        }
        dropDown.cellNib = UINib(nibName: "dropCell", bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? dropCell else { return }
        }
        dropDown.bottomOffset = CGPoint(x: 0, y:(self.navigationController?.navigationBar.frame.size.height)!)
    }
    
    
    @IBAction func dropDownCards(_ sender: Any) {
        dropDown.show()
    }
    @IBAction func userPay(_ sender: Any) {
        var selectedData:String = ""
        if(dropDown.indexForSelectedRow != nil)
        {
            selectedData = (track[dropDown.indexForSelectedRow!])!
            print(selectedData)
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: ("Please select a payment option."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                return
                
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let user = Auth.auth().currentUser else
        {
            print("no user")
            return
        }
        let ref: DatabaseReference = Database.database().reference()
        print("we here")
        ref.child("stripe_bar_users").child(barID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            self.prefName = snapshot.childSnapshot(forPath: "acc_id").value as! String
            var actualValue = self.value as String
            actualValue.append("00")
            var refActual: DatabaseReference!
            refActual = ref.child("stripe_customers").child(user.uid).child("charges").childByAutoId()
            refActual.setValue([
                "source" : selectedData,
                "amount" : actualValue as NSString,
                "destination" : self.prefName as NSString,
                "barPrice" : "100" as NSString
                ], withCompletionBlock: {(error, refActual) in
                    if(error != nil)
                    {
                        let alert = UIAlertController(title: "Error", message: (error?.localizedDescription)!, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                            return
                            
                        }))
                        self.present(alert, animated: true, completion: nil)
                        return
                    }
                    else
                    {
                        for item in self.menuPass {
                            let defaults = UserDefaults.standard
                            defaults.set(0, forKey: item.key)
                        }
                        self.addNewReceipt()
                    }
            })
            })
        
        
        
        //if charge status succeeded
        //add new receipt with info such as date bought, time bought and bar name, possibly add button that bouncer can click once receipt has been used
    }
    func formatAmount(number:NSNumber) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: number)!
    }
    @IBAction func userPayLineSkip(_ sender: Any) {
        var selectedData: String = ""
        if(dropDown.indexForSelectedRow != nil)
        {
            selectedData = (track[dropDown.indexForSelectedRow!])!
        }
        else
        {
            let alert = UIAlertController(title: "Error", message: ("Please select a payment option."), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                return
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
        let user = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database().reference()
        var actualValue = value as String
        actualValue.append("00")
        var refActual: DatabaseReference!
        
        refActual = ref.child("stripe_customers").child((user?.uid)!).child("charges").childByAutoId()
        refActual.setValue([
            "source" : selectedData,
            "amount" : actualValue as NSString
            ], withCompletionBlock: {(error, refActual) in
                
                if(error != nil)
                {
                    let alert = UIAlertController(title: "Error", message: (error?.localizedDescription)!, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        return
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                else
                {
                    self.addNewReceiptLineSkip()
                    
                }
        })
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "displayReceipt")
        {
            let dest = segue.destination as! Receipt
            dest.receiptKey = receiptKey
            dest.barName = barName
            dest.date = self.date
            dest.menu = menuPass
        }
        if(segue.identifier == "displayReceiptLineSkip")
        {
            let dest = segue.destination as! Receipt
            dest.receiptKey = receiptKey
            dest.barName = barName
            dest.date = self.date
            dest.menu = menuPass
        }
        
    }
    
    func addNewReceipt()-> Void
    {
        self.date = ServerValue.timestamp() as! [String : Any]
        let user = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        var refActual = Database.database().reference()
        refActual = refActual.child("stripe_customers").child((user?.uid)!).child("receipts").child("wallet")
        ref = refActual.childByAutoId()
        ref.setValue(["isExpired": false,
                      "barName": barName,
                      "isLineSkip": false,
                      "date" : self.date,
            "menuItems": menuPass], withCompletionBlock: {(error, ref) in
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
                            self.performSegue(withIdentifier: "displayReceipt", sender: self)
                        }
                        
        })
        receiptKey = ref.key!
    }
    func addNewReceiptLineSkip()-> Void
    {
        self.date = ServerValue.timestamp() as! [String : Any]
        let user = Auth.auth().currentUser
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        var refActual = Database.database().reference()
        refActual = refActual.child("stripe_customers").child((user?.uid)!).child("receipts")
        ref = refActual.childByAutoId()
        ref.setValue(["isExpired": false,
                      "barName": barName,
                      "isLineSkip": true,
                      "date": self.date], withCompletionBlock: {(error, ref) in
                        
                        if(error != nil)
                        {
                            let alert = UIAlertController(title: "Error", message: (error?.localizedDescription)!, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                                return
                                
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else{
                            self.performSegue(withIdentifier: "displayReceiptLineSkip", sender: self)
                        }
                        
        })
        receiptKey = ref.key!
        
    }
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return true
    }
    override func viewDidAppear(_ animated: Bool) {
        var data : [String] = []
        print(pickerData.count)
        for item in pickerData
        {
            print(item)
            data.append(item)
        }
        dropDown.anchorView = picker
        dropDown.dataSource = data
        dropDown.reloadAllComponents()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
