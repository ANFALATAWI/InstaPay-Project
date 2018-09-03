//
//  createCobonViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 24/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
import Alamofire
import AlamofireImage

class createCobonViewController: UIViewController {
    
    //Vars:
    var ref:DatabaseReference?
    var background = ["card3"]
    var balance:Int?
    var customer =  ((metadataObj?.stringValue!)!)
    
    //Constants :
    let defaultBackgroundColor: UIColor = UIColor(white: 0.5, alpha: 0.0)
    let defaultHighlightColor: UIColor = UIColor(white: 0, alpha: 0.4)

    //Outlet:
    @IBOutlet weak var amount: UITextField!
    @IBOutlet var numberPad: NumberPad!
    @IBOutlet weak var olAmount: UIButton!
    @IBOutlet weak var addAmount: UIView!
    @IBOutlet weak var cobonView: UIView!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        ref = Database.database().reference()
        
        
        //this for keyboard ..
        numberPad.style = .circle
        numberPad.clearKeyBackgroundColor = defaultBackgroundColor
        numberPad.clearKeyHighlightColor = defaultHighlightColor
        numberPad.clearKeyTintColor = .white
        numberPad.keyScale = 0.8
        numberPad.delegate = self
        
    }
    
    
    @IBAction func openKeyboard(_ sender: Any) {
      
        //hide ..
        cobonView.isHidden = true
        //view
        addAmount.isHidden = false
    
    }
    
    //for adding amount view and set the amount that user entered
    @IBAction func addAmount(_ sender: Any) {
        
        //fill
        olAmount.setTitle(amount.text! , for: UIControlState.normal)
        //view
        cobonView.isHidden = false
        //view
        addAmount.isHidden = true
        
    }

    
    //buying coupons ...
    @IBAction func payCobon(_ sender: Any) {
        
        //to get current user from firebase ..
        let userID = Auth.auth().currentUser?.uid
        
        
        self.ref?.child("users").child("customer").child(customer).observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Vars:
            var value = snapshot.value as! [String : Any]
            var balance0 = value["userBalance"] as! Int

            //check if user entered amount ..
            if self.amount.text?.isEmpty == true{
                SVProgressHUD.showError(withStatus: " please enter amount!")
                
            //check is user have enough balance
            }else if balance0 == 0 || balance0 < Int(self.amount.text!)!{
                SVProgressHUD.showError(withStatus: "you don't have balance")
                
            }else{

                //to get currnet date ..
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                let dateT = Date()
                dateFormatter.locale = Locale(identifier: "en_US")
                let date = dateFormatter.string(from: dateT)

                //to get random index ..
                let randomIndex = Int(arc4random_uniform(UInt32(self.background.count)))
                
                //customer refrench ..
                let cusRef =  self.ref?.child("users").child("customer").child(self.customer).child("cobons").childByAutoId()
                //merchant refrench ..
                let merRef =  self.ref?.child("users").child("merchants").child(userID!).child("cobons").child((cusRef?.key)!)
                
                //QR information ..
                let identifier = (cusRef?.key)!
                let size = "200"
                let color = "3D344F"
                let bgcolor = "ffffff"
                
                //QR generator API connection ..
                Alamofire.request("https://api.qrserver.com/v1/create-qr-code/?data=\(identifier)&size=\(size)x\(size)&color=\(color)&bgcolor=\(bgcolor)&margin=5").responseImage { response in
                    debugPrint(response)
                    print(response.request)
                    print(response.response)
                    debugPrint(response.result)
                    
                    // upload QR image to firebase storage ..
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        
                        uploadCobonsImage(image) { url in
                            
                            //add coupoun information into firebase
                            
                            let Cobvalues = ["amount" : Int(self.amount.text!),  "merchant" :  userID  , "date": date ,"QRCode" : url?.absoluteString , "isGift": false , "image" : self.background[randomIndex] , "owner" : self.customer ] as [String : Any]
                            
                            let Cobvalues2 = ["amount" : Int(self.amount.text!),  "customer" : self.customer  , "date": date ,"QRCode" : url?.absoluteString] as [String : Any]
                            
                            
                            merRef?.updateChildValues(Cobvalues2, withCompletionBlock: { (error, reference) in
                                if error != nil {
                                    let alert = UIAlertController(title: "Error", message: "some thing wrong", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    return
                                }
                            })
                            
                            cusRef?.updateChildValues(Cobvalues, withCompletionBlock: { (error, reference) in
                                if error != nil {
                                    let alert = UIAlertController(title: "Error", message: "some thing wrong", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    return
                                }
                            })
                        }
                        
                        
                    }}
                
                
                self.doUser() { name in
                    print("done customer")
                }
                
                self.doMerchant(){ name in
                    print("done merchant")
                }
                
               // if every things okey perform segue ..
              self.performSegue(withIdentifier: "done", sender: self)
            }
            
        })}
    
    //completion function to subtact coupon amount from user balance ..
    func doUser( completion : @escaping ( (_ name : String?) -> () ))
    {
        
        let userID = Auth.auth().currentUser?.uid
        self.ref?.child("users").child("customer").child(customer).observeSingleEvent(of: .value, with: { (snapshot) in
            var value = snapshot.value as! [String : Any]
            var customerName =  value["name"] as! String
            self.balance = value["userBalance"] as! Int
            self.balance = self.balance! - Int(self.amount.text!)!
            self.ref?.child("users").child("customer").child(self.customer).child("userBalance").setValue(self.balance)
            completion(customerName)
        })
    }
     //completion function to add coupon amount to merchant balance ..
    func doMerchant( completion : @escaping ( (_ name : String?) -> () )){
        
        let userID = Auth.auth().currentUser?.uid; self.ref?.child("users").child("merchants").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            var value = snapshot.value as! [String : Any]
            var merchantName =  value["name"] as! String
            self.balance = value["merchantBalance"] as! Int
            self.balance = self.balance! + Int(self.amount.text!)!
            self.ref?.child("users").child("merchants").child(userID!).child("merchantBalance").setValue(self.balance)
            completion(merchantName)
        })
    }

}

//for keyborad .. 
extension createCobonViewController: NumberPadDelegate {
    
    func keyPressed(key: NumberKey?) {
        guard let number = key else {
            return
        }
        switch number {
        case .clear:
            guard !(amount.text?.isEmpty ?? true) else {
                return
            }
            amount.text?.removeLast()
        default:
            amount.text?.append("\(number.rawValue)")
        }
    }
}

