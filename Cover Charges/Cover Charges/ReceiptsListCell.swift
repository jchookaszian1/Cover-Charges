//
//  ReceiptsListCell.swift
//  Cover Charges
//
//  Created by Joe Chookaszian on 9/11/17.
//  Copyright © 2017 Joe Chookaszian. All rights reserved.
//

import UIKit

class ReceiptsListCell: UITableViewCell {


    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var barName: UILabel!
    var receiptKey = ""
    var ID: ReceiptStruct? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
