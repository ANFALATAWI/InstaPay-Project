//
//  AddFreindViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 16/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD


class AddFreindViewController: UIViewController {
    
    @IBOutlet weak var FreindName: UILabel!
    
    var ref:DatabaseReference?
    @IBOutlet weak var friendQr: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.ref = Database.database().reference()
        var friend = ((metadataObj?.stringValue!)!)
        self.ref?.child("users").child("customer").observe(.childAdded) {(snapshot) in
            
            print(snapshot.key)
            
            if snapshot.key == friend {
                var value = snapshot.value as! [String : Any]
                self.FreindName.text = value["name"] as! String
                
                let url = value["QRCode"] as? String
                print("Got image url.")
                print(url!)
                
                // Create a reference to the file you want to download
                let storageRef = Storage.storage()
                let httpsReference = storageRef.reference(forURL: url!)
                print("Got Image ref.")
                
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error! no image!!")
                        print(error)
                        // Uh-oh, an error occurred!
                    } else {
                        // Data for "images/island.jpg" is returned
                        let image = UIImage(data: data!)
                        print("Entered without error and got image.")
                        self.friendQr.image = image
                        print("Displayed image.")
                    }
                }
            } else {
                print("error")
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        performSegue(withIdentifier: "cancelFriendsShip", sender: self)
    }
    
    
    @IBAction func AddFreind(_ sender: Any) {
        
        self.ref = Database.database().reference()
        
        var friend = ((metadataObj?.stringValue!)!)
        let userID = Auth.auth().currentUser?.uid
        
        let usersReference = self.ref?.child("users").child("customer").child(userID!).child("friends").childByAutoId()
        let values = ["FriendID" : friend ] as [String : Any]
        
        usersReference?.updateChildValues(values, withCompletionBlock: { (error, reference) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "some thing wrong", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
        })
        
        let friendReference = self.ref?.child("users").child("customer").child(friend).child("friends").childByAutoId()
        let values2 = ["FriendID" : userID! ] as [String : Any]
        
        friendReference?.updateChildValues(values2, withCompletionBlock: { (error, reference) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "some thing wrong", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                return
            }
        })
        self.performSegue(withIdentifier: "doneAddedFriend", sender: self)
    }
    
}


