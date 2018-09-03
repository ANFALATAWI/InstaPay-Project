//
//  TransactionCell.swift
//  madfo3
//
//  Created by Ebtsam alkhuzai on 11/3/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {

    @IBOutlet weak var transactionAmount: UILabel!
    @IBOutlet weak var transactionDate: UILabel!
    @IBOutlet weak var transactionName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
