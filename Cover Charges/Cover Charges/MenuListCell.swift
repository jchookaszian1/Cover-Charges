//
//  MenuListCell.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 1/20/18.
//  Copyright © 2018 Joe Chookaszian. All rights reserved.
//

import UIKit

class MenuListCell: UITableViewCell {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
