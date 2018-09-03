//
//  sendToFriendsViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 19/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class sendToFriendsViewController: UIViewController, UITableViewDataSource , UITableViewDelegate {
    
    //Vars:
    var friendsNames = [Friends]()
    var friends = [Friends]()
    var friend : String?
    var ref:DatabaseReference?
    
    //Outlet"
    @IBOutlet weak var sendToFriend: UIButton!
    @IBOutlet weak var selectedFriend: UILabel!
    @IBOutlet weak var friendsTableView: UITableView!
    
    
    
    override func viewDidLoad() {
    super.viewDidLoad()
    bringMyFriends()

    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //this function to bring all my friends from firebase
    func bringMyFriends(){
    
    self.ref = Database.database().reference();
        //to get currend user id
         let userID = Auth.auth().currentUser?.uid
     
    self.ref?.child("users").child("customer").child(userID!).child("friends").observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                self.friends.removeAll()
                self.friendsNames.removeAll()
    
          for friend in snapshot.children.allObjects as![DataSnapshot]{
                let fri = friend.value as? [String: Any]
                let frie = fri?["FriendID"]
        
     self.ref?.child("users").child("customer").child(frie as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                var value = snapshot.value as! [String : Any]
                let name = value["name"] as! String
                let frie = Friends(friendName: name,friendId: frie as! String)
                self.friendsNames.append(frie)
                self.friendsTableView.reloadData()
         })
        }
    }}
 )}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return friendsNames.count
    }
    
    //to fill cell with friends information ..
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! sendToFriendsCell
    var friendCell :Friends
    friendCell = self.friendsNames[indexPath.row]
    cell.friendName.text = friendCell.friendName
    return cell
    
    }
    
    //to get selected friend id
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var friendCell :Friends
        friendCell = self.friendsNames[indexPath.row]
        self.friend = friendCell.friendId
        
        selectedFriend.text = friendCell.friendName
        selectedFriend.isHidden = false
        sendToFriend.isHidden = false
    }
    
    //to send this coubon as a gift to friend ..
    @IBAction func sendToFriendAction(_ sender: Any) {

        //to get current user ..
        let userID = Auth.auth().currentUser?.uid
        
      //to get merchant's name..
      let userRef =  self.ref?.child("users").child("customer").child(userID!).child("cobons").child(cobonIds!).observeSingleEvent(of: .value, with: { (snapshot) in
            var value = snapshot.value as! [String : Any]
            let merchant = value["merchant"]
           
      //upadate coubons information in merchant node ..
      let merRef = self.ref?.child("users").child("merchants").child(merchant! as! String).child("cobons").child(cobonIds!).child("customer").setValue(self.friend!)
        
        //add coubon as a gift in frind account
            let friendRef =  self.ref?.child("users").child("customer").child(self.friend!).child("cobons").child(cobonIds!)
            
            friendRef?.updateChildValues(value, withCompletionBlock: { (error, reference) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "some thing wrong", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
            //uadate this coubon as a gift..
            let gifRef = self.ref?.child("users").child("customer").child(self.friend!).child("cobons").child(cobonIds!).child("isGift").setValue(true)
                
                
            })})
        
        //delete this coubon frin user account..
        let userdeleteRef =  self.ref?.child("users").child("customer").child(userID!).child("cobons").child(cobonIds!).removeValue()
        
        // if everything okey perform segue .. 
        performSegue(withIdentifier: "doneGift", sender: self)
    }
            
}
        


