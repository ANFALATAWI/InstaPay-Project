//
//  FriendsViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 18/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class FriendsViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {
    
    
    //Vars:
    var friendsNames = [Friends]()
    var friends = [Friends]()
    var ref:DatabaseReference?
    
    //Outlet:
    @IBOutlet var frendView: UIView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var friendsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bringMyFriends()
    }
    
    
    //to get user's frinds from firebase ..
    func bringMyFriends(){
        
        self.ref = Database.database().reference();
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
            }else {
                self.emptyView.isHidden = false
                self.friendsTableView.isHidden = true
            } }
        )}
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsNames.count
    }
    
    //Fill table vire with frind information .. 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! FriendsCell
    var friendCell :Friends
        friendCell = self.friendsNames[indexPath.row]
        cell.FriendsName.text = friendCell.friendName
        return cell

    }

}
