//
//  Transaction.swift
//  madfo3
//
//  Created by Anfal Alatawi on 02/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import Foundation

class Transaction{
//    var receiver : User
    var receiver: String?
    var time:String?
    var amount:Int?
    var message: String?
    var dateTime: String?

    init (){
    }
    init(receiver: String?, amount : Int? , date: String? , time: String?) {

        self.receiver = receiver;
        self.amount = amount!;
        self.dateTime = date;
        self.time = time;

    }
    
    init(amount : Int?) {
        self.amount = amount!
    }
    
    func getAmount() -> Int{
        if amount != nil{
            return amount!}
        return 5
    }
    

}
