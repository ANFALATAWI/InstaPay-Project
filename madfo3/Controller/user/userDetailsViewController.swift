//
//  DetailsViewController.swift
//  instaPay
//
//  Created by Anfal Alatawi on 18/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//


//TODO:
//Connect with database.

import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
import FirebaseAuth
import FirebaseStorage

class userDetailsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var ref = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    
    //OUTLETS:
    @IBOutlet weak var CardsTable: UITableView!
    
    //Labels:
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    //TextFields:
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    
    //Views:
    @IBOutlet weak var checkButtonView: UIView!
    @IBOutlet weak var editButtonView: UIView!
    
    @IBAction func editButton(_ sender: UIButton) {
        
        //hide:
        nameLabel.isHidden = true
        phoneLabel.isHidden = true
        emailLabel.isHidden = true
        editButtonView.isHidden = true
        
        //fill:
        nameTextField.text = nameLabel.text
        emailTextField.text = emailLabel.text
        mobileTextField.text = phoneLabel.text
        
        //show:
        nameTextField.isHidden = false
        emailTextField.isHidden = false
        mobileTextField.isHidden = false
        checkButtonView.isHidden = false
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        
        nameLabel.text = nameTextField.text
        emailLabel.text = emailTextField.text
        phoneLabel.text = mobileTextField.text
        
        nameTextField.isHidden = true
        emailTextField.isHidden = true
        mobileTextField.isHidden = true
        checkButtonView.isHidden = true
        
        nameLabel.isHidden = false
        phoneLabel.isHidden = false
        emailLabel.isHidden = false
        editButtonView.isHidden = false
        
        //save remotly
        SVProgressHUD.show()
        updateUserProfile()
        SVProgressHUD.dismiss()
        
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //Table controlls:
    
    //Dummy data***:
    var cardsList : [String] = ["Anfal Alatawi", "Sarah Alahmad", "Mohammad Jaber"]
    var cardNumbers :[String] = ["xxxx xxxx xxxx 4568", "xxxx xxxx xxxx 4568","xxxx xxxx xxxx 4568",]
    var cardExp : [String] = ["10/18", "12/20", "01/06"]
    var cardImages : [String] = ["1","2","3"]
    //****
    
    //returns appropriate number of cells to be loaded in table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardsList.count
    }
    
    //loads table cells.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CardTableViewCell
        
        cell.cardHolderName.text = cardsList[indexPath.row]
        cell.cardNumber.text = cardNumbers[indexPath.row]
        cell.cardExpDate.text = cardExp[indexPath.row]
        cell.cardImage.image = UIImage(named: cardImages[indexPath.row] + ".png")
        
        return cell
    }
    
    //resizing table cells:
    override func viewWillAppear(_ animated: Bool) {
        CardsTable.estimatedRowHeight = 100
        CardsTable.rowHeight = UITableViewAutomaticDimension
    }
    //end of table controlls:
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CardsTable.delegate = self
        CardsTable.dataSource = self
        SVProgressHUD.show()
        
        // hide / show labels and fields:
        nameTextField.isHidden = true
        emailTextField.isHidden = true
        mobileTextField.isHidden = true
        checkButtonView.isHidden = true
        editButtonView.isHidden = false
        
        //load data from data base:
        ref.child("users").child("customer").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            var value = snapshot.value as? [String : Any]
            self.nameLabel.text = value!["name"] as! String
            self.emailLabel.text = value!["email"] as! String
            self.phoneLabel.text = value!["phone"] as! String
        })
        
        // Do any additional setup after loading the view.
        SVProgressHUD.dismiss()
    }
    
    func updateUserProfile()
    {
        //check to see if the user is logged in
        if let userID = Auth.auth().currentUser?.uid {
                guard let newName  = self.nameTextField.text else {return}
                guard let newEmail = self.emailTextField.text else {return}
                guard let newMobile = self.mobileTextField.text else {return}
                
                let newValuesForProfile = ["email": newEmail,
                                           "name" : newName ,
                                           "phone" : newMobile]
                
                //update the firebase database for that user
                self.ref.child("users").child("customer").child(userID).updateChildValues(newValuesForProfile, withCompletionBlock: { (error, ref) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    print("Profile Successfully Update")
                })
            }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
