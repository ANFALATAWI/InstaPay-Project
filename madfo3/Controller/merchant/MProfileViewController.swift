//
//  MProfileViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 11/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

//TODO:
//Segue to QR View, transferring image between views:

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
import FirebaseAuth

class MProfileViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{
    
    //Vars:
    var ref:DatabaseReference?
    var transactions = [Transaction]()
    
    //OUTLETS:
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var merchantImage: UIImageView!
    @IBOutlet weak var transactionTableView: UITableView!
    
    //segue to transfer image to other view. *Incomplete*
    @IBAction func qrButton(_ sender: Any)
    {
        performSegue(withIdentifier: "profileSegue" , sender: self)
    }
    
    //Log Out function:
    @IBAction func logOutButton(_ sender: UIButton)
    {
        
        print(Auth.auth().currentUser!)
        do {
            try Auth.auth().signOut()
        }
        catch let logOutError {
            print(logOutError)
        }
        
        //displaying current user:
        
        //showing the initial storyboard:
        let storyBoard = UIStoryboard(name: "LogInSignUp" , bundle: nil)
        let signInVC = storyBoard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(signInVC, animated: true, completion: nil)
        
        //showing message:
        SVProgressHUD.showSuccess(withStatus: "Signed out")
        
    }
    
    //returning table count to tell table number of cells to load:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    //Loading cells:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! TransactionCell
        
        var transactionCell :Transaction
        transactionCell = self.transactions[indexPath.row]
        cell.transactionAmount.text = NSString(format:"%d", transactionCell.amount!) as String
        cell.transactionName.text = transactionCell.receiver
        cell.transactionDate.text = transactionCell.dateTime
        
        return cell
    }
    
    //Cancel Function:
    @IBAction func canecl(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //creating a reference to the databse:
        self.ref = Database.database().reference()
        let userID = Auth.auth().currentUser?.uid
        print("Current user ID: \(userID!)")
        
        //getting the currents user's value dictionary from database:
        ref?.child("users").child("merchants").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            //saving it as a dictionary:
            var value = snapshot.value as? [String : Any]
            
            //saving data I need:
            self.userName.text = value!["name"] as? String
            let balance = value!["merchantBalance"]
            self.balance.text = NSString(format:"%d",balance! as! Int) as String
            
            //image code: ------------------------------------------------------------------------------- start
            //get image
            let url = value!["QRCode"] as? String
            print("Got image url. that we dont need lol.")
            
            // Create a reference to the file you want to download
            let storageRef = Storage.storage()
            let httpsReference = storageRef.reference(forURL: url!)
            print("Got Image ref.")
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if error != nil {
                    print("Error! no image!!")
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)
                    print("Entered without error and got image.")
                    self.merchantImage.image = image
                    print("Displayed image.")
                    
                }
            }
            //image code: ------------------------------------------------------------------------------- end
        })
        
        //getting the currents user's transaction value dictionary from database:
        ref?.child("users").child("merchants").child(userID!).child("transactionsHistory").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //making sure transactions are not null
            if snapshot.childrenCount > 0 {
                
                self.transactions.removeAll()
                
                //getting single transaction:
                for tran in snapshot.children.allObjects as![DataSnapshot]{
                    let trans = tran.value as? [String: Any]
                    let sender = trans?["sender"]
                    let amount = trans?["amount"]
                    let date = trans?["date"]
                    let time = trans?["time"]
                    let transa = Transaction(receiver: sender as! String? , amount:amount as! Int? , date:date as! String?, time:time as! String?)
                    self.transactions.append(transa)
                    print(sender!)
                    
                }
                
                //refreshing table:
                self.transactionTableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
