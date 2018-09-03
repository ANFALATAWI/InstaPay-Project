//
//  Cobons.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 18/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import Foundation
class Cobons {
    var merchantID : String?
    var merchantName: String?
    var cobonAmount:Int?
    var cobonDate : String?
    var QR:String?
    var cobonId:String?
    var isGigt:Bool?
    var background:String?
    var ownerID : String?
    var Customername: String?
    
    
    init (){
    }
    init(cobonId:String? , merchantID: String? , cobonAmount: Int? , cobonDate : String? , QR:String? , merchantName:String? , isGift:Bool? , background:String? , ownerID:String? , Customername:String?) {
        
        self.cobonId = cobonId
        self.merchantID = merchantID
        self.QR = QR
        self.cobonAmount=cobonAmount
        self.cobonDate = cobonDate
        self.merchantName = merchantName
        self.isGigt = isGift
        self.background = background
        self.ownerID = ownerID
        self.Customername = Customername
    }
    
    
}
