//
//  SignUpSignInViewController.swift
//  madfo3
//
//  Created by Anfal Alatawi on 03/11/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.

import UIKit
import Firebase
import FirebaseDatabase
import Alamofire
import AlamofireImage
import SVProgressHUD

var circleBox = Checkbox(frame: CGRect(x: 100, y: 140, width: 25, height: 25))
var circleBox2 = Checkbox(frame: CGRect(x: 100, y: 190, width: 25, height: 25))

class SignUpViewController: UIViewController , UITextFieldDelegate ,UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    @IBOutlet weak var third2: UIView!
    @IBOutlet weak var third: UIView!
    @IBOutlet weak var fourth: UIView!
    @IBOutlet weak var first: UIView!
    @IBOutlet weak var seound: UIView!
    @IBOutlet weak var cSignUpName: UITextField!
    @IBOutlet weak var mSignUpPhone: UITextField!
    @IBOutlet weak var cSignUpPhone: UITextField!
    @IBOutlet weak var mSignUpName: UITextField!
    @IBOutlet weak var signUpPassword: UITextField!
    @IBOutlet weak var signUpEmail: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var user = User()
    var ref = Database.database().reference()
    var userBalance = 1000
    var merchantBalance = 0
    var x : UIImage?
    var code : String?


    @IBAction func importButton(_ sender: Any) {
        
        let image = UIImagePickerController()
        image.delegate = self
        
        image.sourceType = UIImagePickerControllerSourceType.photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            //After it is complete
            
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imageView.image = image
            print("After image view")
            x = image}
            
        else
        {
            //Error message
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // move to next view
    @IBAction func firstButton(_ sender: Any) {
        
        // validate if all textfields is not empty ..
        if signUpEmail.text?.isEmpty == true  &&  signUpPassword.text?.isEmpty == true
        {
            
            let alert = UIAlertController(title: "WRONG", message: "Your email is Empty and password is empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
            
            // check if only email is empty ..
        }else if signUpEmail.text?.isEmpty == true {
            let alert = UIAlertController(title: "WRONG", message: "Your password and email id empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
             // check if email is valid .
        }else if isValidEmail(testStr: signUpEmail.text!) == false {
            let alert = UIAlertController(title: "WRONG", message: "Your email is wrong", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
            // check if only password is empty ..
        }else if signUpPassword.text?.isEmpty == true {
            
            let alert = UIAlertController(title: "WRONG", message: "Your password Empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
         
            // check if password is less than 6
        } else if (signUpPassword.text?.count)! <= 6 {
            let alert = UIAlertController(title: "WRONG", message: "Your password must br 6 or more", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
            
        } else {
            
            //check if merchant email exists:
            merchantExists(email: signUpEmail.text!) { existence in
                if existence! {
                    SVProgressHUD.showError(withStatus: "User Exists!")
                }
                else
                {
                    //Check if customer exists:
                    customerExists(email: self.signUpEmail.text!) { existence in
                        if existence! {
                            SVProgressHUD.showError(withStatus: "User Exists!")
                        }
                        else
                        {
                            //Continue otherwisee:
                            self.first.isHidden = true
                            self.seound.isHidden = false
                        }
                    }
                }
            }
        }
    }
    
    // move to next view
    
    @IBAction func secoundButton(_ sender: Any) {
        
        
        seound.isHidden = true
        
        if circleBox.isChecked == true {
            third.isHidden = false
        }else if (circleBox.isChecked == false && circleBox2.isChecked == false){
            seound.isHidden = false
            let alert = UIAlertController(title: "WRONG", message: "Your must choose one", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
        if circleBox2.isChecked == true {
            fourth.isHidden = false
        }else if (circleBox.isChecked == false && circleBox2.isChecked == false){
            seound.isHidden = false
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addCheckboxSubviews()
        self.signUpEmail.delegate = self
        self.signUpPassword.delegate = self
        self.mSignUpName.delegate = self
        self.mSignUpPhone.delegate = self
        self.cSignUpPhone.delegate = self
        self.cSignUpName.delegate = self
        
    }
    
    
    func addCheckboxSubviews() {
        
        circleBox.borderStyle = .circle
        circleBox.checkmarkStyle = .circle
        circleBox.borderWidth = 1
        circleBox.uncheckedBorderColor = .lightGray
        circleBox.checkedBorderColor = .gray
        circleBox.checkmarkSize = 0.8
        circleBox.checkmarkColor = .black
        seound.addSubview(circleBox)
        
        circleBox2.borderStyle = .circle
        circleBox2.checkmarkStyle = .circle
        circleBox2.borderWidth = 1
        circleBox2.uncheckedBorderColor = .lightGray
        circleBox2.checkedBorderColor = .gray
        circleBox2.checkmarkSize = 0.8
        circleBox2.checkmarkColor = .black
        seound.addSubview(circleBox2)
        
        
    }
    
    // for keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if  (textField == self.signUpEmail) {
            self.signUpPassword.becomeFirstResponder()
            
        }
        if  (textField == self.cSignUpName) {
            self.cSignUpPhone.becomeFirstResponder()
            
        }
        if  (textField == self.mSignUpName){
            self.mSignUpPhone.becomeFirstResponder()
            
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //for customer sign up
    @IBAction func cSignUp(_ sender: Any)
    {
        
        if cSignUpName.text?.isEmpty == true  &&  cSignUpPhone.text?.isEmpty == true
        {
            
            let alert = UIAlertController(title: "WRONG", message: "Your name is Empty and phone is empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }else if cSignUpName.text?.isEmpty == true {
            let alert = UIAlertController(title: "WRONG", message: "Your name is empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
        }else if cSignUpPhone.text?.isEmpty == true {
            
            let alert = UIAlertController(title: "WRONG", message: "Your phone Empty", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
            
        } else if validatePhone(value: cSignUpPhone.text!) == false {
            let alert = UIAlertController(title: "WRONG", message: "Your phone is wrong", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            return
            
        } else
        {
            first.isHidden = true
            seound.isHidden = false
        }
        
        //Start Progress HUD:
        SVProgressHUD.show(withStatus: "Creating Profile")
        
        guard let email = signUpEmail.text , let pass = signUpPassword.text , let name = cSignUpName.text , let phone = cSignUpPhone.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email,password: pass, completion: {  (result, error) in
            if (error != nil){
                
                return
            }
            guard let uid = result?.user.uid else {
                return
            }
            
            let usersReference = self.ref.child("users").child("customer").child(uid)
            let identifier = uid //ONLY change this value with value from database
            let size = "200"
            let color = "ffffff"
            let bgcolor = "3D344F"
            
            Alamofire.request("https://api.qrserver.com/v1/create-qr-code/?data=\(identifier)&size=\(size)x\(size)&color=\(color)&bgcolor=\(bgcolor)&margin=5").responseImage { response in
                debugPrint(response)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    //End of generating QR Code
                    
                    //Uploading image to Storage
                    uploadCustomerQrImage(image) { url in
                        
                        //Uploading profile image:
  
            let values = ["email": email, "name" : name , "phone" : phone , "userBalance" : self.userBalance , "QRCode" : url?.absoluteString,] as [String : Any]
            
            usersReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "some thing wrong", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
                
                //End Progress HUD:
                SVProgressHUD.dismiss()
                
                //Perform Segue
                self.performSegue(withIdentifier: "cGoToHome", sender: self)
               
                SVProgressHUD.showSuccess(withStatus: "Successfully Signed up!")
                
            })
                            //User data stored & going home
                        
                    }
                }
            }
            
        }) //End of creating user
        print("your email \(email) your password \(pass) ")
        
        
    }
    
    
    // merchant sign up
    @IBAction func mSignUp(_ sender: Any)
    {
        //start progress hud:
        SVProgressHUD.show(withStatus: "Creating Profile")
        
        guard let email = self.signUpEmail.text , let pass = self.signUpPassword.text , let name = self.mSignUpName.text , let phone = self.mSignUpPhone.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email,password: pass, completion: {  (result, error) in
            if (error != nil){
                return
            }
            guard let uid = result?.user.uid else {
                return
            }
            
            let usersReference = self.ref.child("users").child("merchants").child(uid)
            
            
            //Generating QR Code:
            
            let identifier = uid //ONLY change this value with value from database
            let size = "200"
            let color = "ffffff"
            let bgcolor = "3D344F"
            
            Alamofire.request("https://api.qrserver.com/v1/create-qr-code/?data=\(identifier)&size=\(size)x\(size)&color=\(color)&bgcolor=\(bgcolor)&margin=5").responseImage { response in
                debugPrint(response)
                print(response.request)
                print(response.response)
                debugPrint(response.result)
                
                if let image = response.result.value {
                    print("image downloaded: \(image)")
                    //End of generating QR Code
                    
                    //Uploading image to Storage
                    uploadMerchantQrImage(image) { url in
                        
                        //Uploading profile image:
                        uploadMerchantImage(self.imageView.image!) { url2 in
                            
                            print(url)
                            print(url2)
                            
                            let values = ["email": email, "name" : name , "phone" : phone , "merchantBalance": self.merchantBalance, "QRCode" : url?.absoluteString, "merchantimage" : url2?.absoluteString ] as [String : Any]
                            
                            usersReference.updateChildValues(values, withCompletionBlock: { (error, reference) in
                                if error != nil {
                                    let alert = UIAlertController(title: "Error", message: "some thing wrong", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    return
                                }
                                
                                print("User data succeessfully stored.")
                                
                                //End Progress HUD:
                                SVProgressHUD.dismiss()
                                
                                //Perform Segue
                                self.performSegue(withIdentifier: "mGoToHome", sender: self)
                                print("Segue performed.")
                                
                                SVProgressHUD.showSuccess(withStatus: "Successfully Signed up!")
                                
                            })
                            //User data stored & going home
                        }
                    }
                }
            }
            
        }) //End of creating user
        print("your email \(email) your password \(pass) ")
        
        
    }
    
    @IBAction func thirdButton(_ sender: Any)
    {
        
        mSignUpPhone.endEditing(true)
        third.isHidden = true
        third2.isHidden = false
        
    }
    
    
    func validatePhone(value: String) -> Bool {
        let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func isValidEmail(testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
}

func uploadMerchantQrImage(_ image:UIImage, completion: @escaping ((_ url :URL?)->())) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let storageRef = Storage.storage().reference().child("merchants/\(uid)")
    
    guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
    
    
    let metaData = StorageMetadata()
    metaData.contentType = "image/jpg"
    
    storageRef.putData(imageData, metadata: metaData) { metaData, error in
        if error == nil, metaData != nil {
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                completion(url)
            }
            
        } else {
            // failed
            completion(nil)
        }
    }
}


//Uploading image to Storage Function
func uploadCustomerQrImage(_ image:UIImage, completion: @escaping ((_ url :URL?)->())) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let storageRef = Storage.storage().reference().child("customer/\(uid)")
    
    guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
    
    
    let metaData = StorageMetadata()
    metaData.contentType = "image/jpg"
    
    storageRef.putData(imageData, metadata: metaData) { metaData, error in
        if error == nil, metaData != nil {
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                completion(url)
            }
            
        } else {
            // failed
            completion(nil)
        }
    }
}

//Uploading merchantimage
func uploadMerchantImage(_ image:UIImage, completion: @escaping ((_ url2 :URL?)->())) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let storageRef = Storage.storage().reference().child("merchantImages/\(uid)- image")
    
    guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
    
    
    let metaData = StorageMetadata()
    metaData.contentType = "image/jpg"
    
    storageRef.putData(imageData, metadata: metaData) { metaData, error in
        if error == nil, metaData != nil {
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                
                completion(url)
            }
            
        } else {
            // failed
            completion(nil)
        }
    }
}




func merchantExists(email : String, completion: @escaping ((_ existence : Bool?)->()))
{
    //database Ref:
    let checkWaitingRef = Database.database().reference()
    var exists = false;
    
    checkWaitingRef.child("users").child("merchants").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
        
        //If there are no users with that email:
        if ( snapshot.value is NSNull ) {
            print("(not found)")
            
            //show error:
            //SVProgressHUD.showError(withStatus: "User Not Found")
            completion(false)
            
        } else { //if there are users with that email: continue.
            print(snapshot.value)
            print("User found")
            
            //verify email:
            //self.emailVerify(email)
            completion(true)
        }
    })
}

func customerExists(email : String, completion: @escaping ((_ existence : Bool?)->()))
{
    //database Ref:
    let checkWaitingRef = Database.database().reference()
    var exists = false;
    
    checkWaitingRef.child("users").child("customer").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
        
        //If there are no users with that email:
        if ( snapshot.value is NSNull ) {
            print("(not found)")
            
            //show error:
            //SVProgressHUD.showError(withStatus: "User Not Found")
            completion(false)
            
        } else { //if there are users with that email: continue.
            print(snapshot.value)
            print("User found")
            
            //verify email:
            //self.emailVerify(email)
            completion(true)
        }
    })
}



