//
//  BarSelectionCell.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 1/10/18.
//  Copyright © 2018 Joe Chookaszian. All rights reserved.
//

import UIKit

class BarSelectionCell: UITableViewCell {


    @IBOutlet weak var barName: UILabel!
    var barID:String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
