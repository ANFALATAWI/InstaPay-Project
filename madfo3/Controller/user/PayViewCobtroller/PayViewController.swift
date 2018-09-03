import UIKit
import Firebase
import FirebaseDatabase
import SVProgressHUD
import Alamofire
import AlamofireImage

class PayViewController: UIViewController  {
    
    
    //Vars:
    var balance:Int?
    var ref:DatabaseReference?
    var merchant =  ((metadataObj?.stringValue!)!)
    
    //Constant:
    let defaultBackgroundColor: UIColor = UIColor(white: 0.5, alpha: 0.0)
    let defaultHighlightColor: UIColor = UIColor(white: 0, alpha: 0.4)
    
    //Outlet:
    @IBOutlet weak var merchabtImage: UIImageView!
    @IBOutlet weak var merchantName: UILabel!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var addAmountView: UIView!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet var numberPad: NumberPad!
    @IBOutlet weak var amountButton: UIButton!


    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //To Fill PayView with Merchant detected QR ..
        ref = Database.database().reference()
        self.ref?.child("users").child("merchants").observe(.childAdded) {(snapshot) in
            print(snapshot.key)
            
            if snapshot.key == self.merchant {
                var value = snapshot.value as! [String : Any]
                self.merchantName.text = value["name"] as! String

                let url = value["merchantimage"] as? String
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
                        self.merchabtImage.image = image
                        print("Displayed image.")
                    }
                }
            } else {
                print("error")
            }
        }
        
        //For keyboard ..
        numberPad.style = .circle
        numberPad.clearKeyBackgroundColor = defaultBackgroundColor
        numberPad.clearKeyHighlightColor = defaultHighlightColor
        numberPad.clearKeyTintColor = .white
        numberPad.keyScale = 0.8
        numberPad.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openAddAmount(_ sender: Any) {
        //Hide
        payView.isHidden = true
        
        //View
        addAmountView.isHidden = false
    }
    
    //when user done added the amount
    @IBAction func addAmount(_ sender: Any) {
        //set the value of entered amount..
        amountButton.setTitle(amount.text! , for: UIControlState.normal)
        
        //View
        payView.isHidden = false
        
        //hide
        addAmountView.isHidden = true
        
    }
    
   
    //When user click pay button..
    @IBAction func pay(_ sender: Any) {

        let userID = Auth.auth().currentUser?.uid
        self.ref?.child("users").child("customer").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            var value = snapshot.value as! [String : Any]
            var balance0 = value["userBalance"] as! Int
            
           //check if user enterd amount ..
            if self.amount.text?.isEmpty == true{
            SVProgressHUD.showError(withStatus: " please enter amount!")
            //check if the user have enough balance..
            }else if balance0 == 0  || balance0 < Int(self.amount.text!)!{
            SVProgressHUD.showError(withStatus: "you don't have balance")
            
                
        }else{
        //to get current date ..
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let dateT = Date()
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = dateFormatter.string(from: dateT)
        
                
        //add transaction info in customer node in firebase ..
        self.doMerchant() { name in
            let usersRef =  self.ref?.child("users").child("customer").child(userID!).child("transactionsHistory").childByAutoId()
            
            //transaction ref:
            let Tranvalues = ["amount" : Int(self.amount.text!),  "receiver" : name , "date": date ] as [String : Any]
            
            
            usersRef?.updateChildValues(Tranvalues, withCompletionBlock: { (error, reference) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "some thing wrong", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
            })
          
            
        }
     //add transaction info in merchant node in firebase ..
        self.doUser() { name in

            var merchant =  ((metadataObj?.stringValue!)!)
            let usersRef2 =  self.ref?.child("users").child("merchants").child(merchant).child("transactionsHistory").childByAutoId()
                 let Tranvalues2 = [ "amount" :   Int(self.amount.text!) , "sender" : name , "date": date ] as [String : Any]
            
            usersRef2?.updateChildValues(Tranvalues2, withCompletionBlock: { (error, reference) in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: "some thing wrong", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                    return
                }
            })
            }}
       })
        
    //when done with transaction perform the segue ..
     self.performSegue(withIdentifier: "done", sender: self)
    }

    //subtract amount from user balance ..
    func doUser( completion : @escaping ( (_ name : String?) -> () ))
    {
        
        let userID = Auth.auth().currentUser?.uid
        self.ref?.child("users").child("customer").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            var value = snapshot.value as! [String : Any]
            var customerName =  value["name"] as! String
            self.balance = value["userBalance"] as! Int
            self.balance = self.balance! - Int(self.amount.text!)!
            self.ref?.child("users").child("customer").child(userID!).child("userBalance").setValue(self.balance)
            completion(customerName)
        })
    }
    
     //add amount to merchant balance ..
    func doMerchant( completion : @escaping ( (_ name : String?) -> () ))
    {
        
        var merchant =  ((metadataObj?.stringValue!)!)
        print(merchant)
        self.ref?.child("users").child("merchants").child(merchant).observeSingleEvent(of: .value, with: { (snapshot) in
            var value = snapshot.value as! [String : Any]
            var merchantName =  value["name"] as! String
            self.balance = value["merchantBalance"] as! Int
            self.balance = self.balance! + Int(self.amount.text!)!
            self.ref?.child("users").child("merchants").child(merchant).child("merchantBalance").setValue(self.balance)
            completion(merchantName)
        })
    }
    
    

}

//for keyboard
extension PayViewController: NumberPadDelegate {
    
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

//upload coubon background image to firebase storage ..
func uploadCobonsImage(_ image:UIImage, completion: @escaping ((_ url :URL?)->())) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    let storageRef = Storage.storage().reference().child("cobons/\(uid)")
    
    guard let imageData = UIImageJPEGRepresentation(image, 0.75) else { return }
    let metaData = StorageMetadata()
    metaData.contentType = "image/jpg"
    
    storageRef.putData(imageData, metadata: metaData) { metaData, error in
        if error == nil, metaData != nil {
            storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
                }
                
                completion(url)
            }
            
        } else {
            completion(nil)
        }
    }
}
