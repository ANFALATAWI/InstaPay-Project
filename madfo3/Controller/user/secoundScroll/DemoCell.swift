//
//  DemoCell.swift
//  FoldingCell
//
//  Created by Alex K. on 25/12/15.
//  Copyright © 2015 Alex K. All rights reserved.
//

import FoldingCell
import UIKit

protocol PlayVideoCellProtocol {
    func playVideoButtonDidSelect()
}


class DemoCell: FoldingCell {
    
    var cobons = [Cobons]()
    var cobonsName = [Cobons]()

    @IBOutlet weak var giftView: UIView!
    var delegate: PlayVideoCellProtocol!

  
    @IBOutlet weak var background: UIImageView!
    
    @IBOutlet weak var giftBackground: UIImageView!
    
    @IBOutlet weak var giftSender: UILabel!
    
    @IBOutlet weak var isGift: UIImageView!
    
    @IBOutlet weak var date: UILabel!

    @IBOutlet weak var merchantName: UILabel!
    
    @IBOutlet weak var isGirt: UIImageView!
    
    @IBOutlet weak var cobonAmount: UILabel!
    
    @IBOutlet weak var olSendGift: UIButton!
    
    @IBOutlet weak var cobonQr: UIImageView!
    var number: Int = 0 {
        didSet {
        }
    }
    

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
  
}

// MARK: - Actions ⚡️

extension DemoCell {
   /*
    @IBAction func deleteFriend(_ sender: Any) {

       self.delegate.playVideoButtonDidSelect()
    }
*/
    
    @IBAction func buttonHandler(_: AnyObject) {
        

    }

    
    
    
 
    
  /*
    @IBAction func favorate(_ sender: Any) {
        
        if (favorate.currentImage == UIImage(named: "star1")) {
        let image = UIImage(named: "star2")
        favorate.setImage(image, for: .normal)
        } else if (favorate.currentImage == UIImage(named: "star2")){
        let image = UIImage(named: "star1")
        favorate.setImage(image, for: .normal)
        }
    }*/
}
