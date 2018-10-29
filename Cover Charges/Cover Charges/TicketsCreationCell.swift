//
//  TicketsCreationCell.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 1/9/18.
//  Copyright © 2018 Joe Chookaszian. All rights reserved.
//

import UIKit

class TicketsCreationCell: UITableViewCell {
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var counter: UIStepper!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var price: UILabel!
    var totalLabel: UILabel!
    var lastValue = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    @IBAction func valueChanged(_ sender: UIStepper) {
        let number = counter.value
        amount.text = Int(number).description
        let defaults = UserDefaults.standard
        defaults.set(Int(number), forKey: itemName.text!)
        if(lastValue > Int(number))
        {
            var priceString = (price.text)!
            priceString = priceString.replacingOccurrences(of: "$", with: "")
            let priceNum = Int(priceString)
            var currPrice = totalLabel.text!
            currPrice = currPrice.replacingOccurrences(of: "$", with: "")
            let currPriceNum = Int(currPrice)
            totalLabel.text = "$" + (currPriceNum! - priceNum!).description
        }
        else
        {
            var priceString = (price.text)!
            priceString = priceString.replacingOccurrences(of: "$", with: "")
            let priceNum = Int(priceString)
            var currPrice = totalLabel.text!
            currPrice = currPrice.replacingOccurrences(of: "$", with: "")
            let currPriceNum = Int(currPrice)
            totalLabel.text = "$" + (currPriceNum! + priceNum!).description
        }
        lastValue = Int(number)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
