//
//  DetailsViewController.swift
//  instaPay
//
//  Created by Anfal Alatawi on 18/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//


import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
import FirebaseAuth
import FirebaseStorage

class DetailsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //creating reference to databse:
    var ref = Database.database().reference()
    
    //getting current user ID:
    let userID = Auth.auth().currentUser?.uid
    
    //OUTLETS:
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var mobileTextField: UITextField!
    
    @IBOutlet weak var buttonEditImageView: UIView!
    @IBOutlet weak var checkButtonView: UIView!
    @IBOutlet weak var editButtonView: UIView!
    
    //Once edit button is clicked:
    @IBAction func editButton(_ sender: UIButton)
    {
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
        buttonEditImageView.isHidden = false
        checkButtonView.isHidden = false
    }
    
    //once save button is clicked, after editing the profile:
    //this takes the data in the fields and saves them.
    @IBAction func saveButton(_ sender: UIButton)
    {
        //extracting data from input fields:
        nameLabel.text = nameTextField.text
        emailLabel.text = emailTextField.text
        phoneLabel.text = mobileTextField.text
        
        //hiding:
        nameTextField.isHidden = true
        emailTextField.isHidden = true
        mobileTextField.isHidden = true
        buttonEditImageView.isHidden = true
        checkButtonView.isHidden = true
        
        //showing:
        nameLabel.isHidden = false
        phoneLabel.isHidden = false
        emailLabel.isHidden = false
        editButtonView.isHidden = false
        
        //saving remotly in DataBase
        SVProgressHUD.show()
        updateUserProfile()
        SVProgressHUD.dismiss()
        
        
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editImage(_ sender: UIButton) {
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            //After it is complete
            
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        
        // hide / show labels and fields:
        nameTextField.isHidden = true
        emailTextField.isHidden = true
        mobileTextField.isHidden = true
        buttonEditImageView.isHidden = true
        checkButtonView.isHidden = true
        editButtonView.isHidden = false
        
        //load data from data base:
        ref.child("users").child("merchants").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            var value = snapshot.value as? [String : Any]
            self.nameLabel.text = value!["name"] as! String
            self.emailLabel.text = value!["email"] as! String
            self.phoneLabel.text = value!["phone"] as! String
            
            
            //getting the image:
            //get image url
            let url = value!["merchantimage"] as? String
            print("Got image url.")
            
            // Create a reference to the file you want to download
            let storageRef = Storage.storage()
            let httpsReference = storageRef.reference(forURL: url!)
            print("Got Image ref.")
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print("Error! no image!!")
                    // Uh-oh, an error occurred!
                } else {
                    // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)
                    print("Entered without error and got image.")
                    self.profileImage.image = image
                    print("Displayed image.")
                    
                }
            }
        })
        
        SVProgressHUD.dismiss()
    }
    
    func updateUserProfile()
    {
        //check to see if the user is logged in
        if let userID = Auth.auth().currentUser?.uid {
            //create an access point for the Firebase storage
            let storageItem = Storage.storage().reference().child("merchantImages/\(userID)- image")
            //get the image uploaded from photo library
            guard let image = profileImage.image else {return}
            if let newImage = UIImageJPEGRepresentation(image, 0.75){
                //upload to firebase storage
                storageItem.putData(newImage, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    storageItem.downloadURL(completion:{(url, error) in
                        if error != nil{
                            print(error!)
                            return
                        }
                        if let profilePhotoURL = url?.absoluteString {
                            guard let newName  = self.nameTextField.text else {return}
                            guard let newEmail = self.emailTextField.text else {return}
                            guard let newMobile = self.mobileTextField.text else {return}
                            
                            let newValuesForProfile = ["email": newEmail,
                                                       "name" : newName ,
                                                       "phone" : newMobile ,
                                                       "merchantimage" : profilePhotoURL ]
                            
                            //update the firebase database for that user
                            self.ref.child("users").child("merchants").child(userID).updateChildValues(newValuesForProfile, withCompletionBlock: { (error, ref) in
                                if error != nil{
                                    print(error!)
                                    return
                                }
                                print("Profile Successfully Update")
                            })
                        }
                    })
                })
            }
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            profileImage.image = image
            print("After image view")
        }
        else
        {
            //Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
