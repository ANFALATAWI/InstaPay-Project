//
//  CardTableViewCell.swift
//  madfo3
//
//  Created by Anfal Alatawi on 05/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit
import QuartzCore

class CardTableViewCell: UITableViewCell {

    //Table Outlets:
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var cardHolderName: UILabel!
    @IBOutlet weak var cardExpDate: UILabel!
    @IBOutlet weak var cardNumber: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
