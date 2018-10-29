//
//  CreditCardCell.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 6/28/18.
//  Copyright © 2018 Joe Chookaszian. All rights reserved.
//

import UIKit

class CreditCardCell: UITableViewCell {
    var barID:String = ""
    @IBOutlet weak var brandNum: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
