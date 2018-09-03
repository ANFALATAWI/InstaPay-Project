//
//  SignInViewController.swift
//  instaPay
//
//  Created by Ebtsam alkhuzai on 08/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import SVProgressHUD

class SignInViewController: UIViewController ,  UITextFieldDelegate
{
    //OUTLETS:
    @IBOutlet weak var signInEmail: UITextField!
    @IBOutlet weak var signInPassword: UITextField!
    
    var ref:DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signInEmail.delegate = self
        self.signInPassword.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //This function is used to auto sign in users.
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        //if there is a current user:
        if Auth.auth().currentUser != nil
        {
            //check if he is a merchant or a customer and choose appropriate segue.
            let uID = Auth.auth().currentUser?.uid
            
            print("User ID:\(uID!)")
            
            ref = Database.database().reference()
            
            //If the user is a Customer preform segue to Customer page
            self.ref?.child("users").child("customer").observe(.childAdded) {(snapshot) in
                print(snapshot.key)
                if snapshot.key == uID {
                    self.performSegue(withIdentifier: "toCustomer", sender: self)
                }
            }
            
            //if the user is a merchant preform segue to merchant page
            self.ref?.child("users").child("merchants").observe(.childAdded) {(snapshot) in
                
                print(snapshot.key)
                if snapshot.key == uID {
                    self.performSegue(withIdentifier: "toMerchants", sender: self)
                }
            }
        } else {print("*** No user! ***")}
    }
    
    //Signing in users:
    @IBAction func signIn(_ sender: UIButton) {
        //Showing ProgressHUD:
        SVProgressHUD.show()
        
        //creating ref to database:
        ref = Database.database().reference()
        
        //getting user email:
        var Email : String = signInEmail.text!
        
        //Checking If user exists:
        userExists(email: signInEmail.text!) { existence in
            
            //checking for correct password is later vv
            
            guard let email = self.signInEmail.text , let pass = self.signInPassword.text else {
                return
            }
            Auth.auth().signIn(withEmail: email, password: pass) { (result, error) in
                if error == nil && result != nil
                {
                    print("Correct password.")
                    let uID = result?.user.uid
                    self.ref?.child("users").child("customer").observe(.childAdded) {(snapshot) in
                        print(snapshot.key)
                        if snapshot.key == uID {
                            print("yaaay!")
                            self.performSegue(withIdentifier: "toCustomer", sender: self)
                        }
                    }
                    
                    self.ref?.child("users").child("merchants").observe(.childAdded) {(snapshot) in
                        
                        if snapshot.key == uID {
                            self.performSegue(withIdentifier: "toMerchants", sender: self)
                        }
                    }
                    
                    //dismissing progressHUD:
                    SVProgressHUD.dismiss()
                    SVProgressHUD.showSuccess(withStatus: "Signed in!")
                    
                } else //Credentials are invalid:
                {
                    //dismissing progressHUD:
                    SVProgressHUD.dismiss()
                    //showing error:
                    SVProgressHUD.showError(withStatus: "Incorrect email or password!")
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    //for keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField == self.signInEmail) {
            self.signInPassword.becomeFirstResponder()
        }
        else if (textField == self.signInEmail){
            textField.resignFirstResponder()
            
        }
        return true
    }
    
    
    
    
    
    //Function that checks if user exists:
    func userExists(email : String, completion: @escaping ((_ existence : Bool?)->()))
    {
        //database Ref:
        let checkWaitingRef = Database.database().reference()
        var exists = false;
        
        checkWaitingRef.child("users").child("merchants").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
            
            //If there are no customers with that email:
            if ( snapshot.value is NSNull ) {
                checkWaitingRef.child("users").child("customer").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with:
                    { snapshot in
                        
                        //If there are no users with that email:
                        if ( snapshot.value is NSNull ) {
                            print("(not found)")
                            
                            //show error:
                            SVProgressHUD.showError(withStatus: "User Not Found")
                            completion(false)
                            
                        } else { //if there are users with that email: continue.
                            print(snapshot.value)
                            print("User found")
                            
                            //verify email:
                            //self.emailVerify(email)
                            completion(true)
                        }
                })
            } else { //if there are users with that email: continue.
                print(snapshot.value)
                print("User found")
                
                //verify email:
                //self.emailVerify(email)
                completion(true)
            }
        })
    }
    
    
    //function incomplete due to lack of private domain for app.
    func emailVerify(_ email : String)
    {
        print("ENTERED EMAIL VERIFY")
        
        //delay here!
        
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://www.example.com")
        // The sign-in operation has to always be completed in the app.
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
        
        Auth.auth().sendSignInLink(toEmail:email, actionCodeSettings: actionCodeSettings)
        { error in
            print("ENTERED OTHER THING.")
            if let error = error {
                print(error.localizedDescription)
                return
            }
            print("Eneterd succesful link mail sent.")
            // The link was successfully sent. Inform the user.
            // Save the email locally so you don't need to ask the user for it again
            // if they open the link on the same device.
            UserDefaults.standard.set(email, forKey: "Email")
            print("Check your email for link")
            // ...
        }
    }
    
}
