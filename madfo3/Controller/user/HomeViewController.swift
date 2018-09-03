//
//  HomeViewController.swift
//  madfo3
//
//  Created by Ebtsam alkhuzai on 11/2/1439 AH.
//  Copyright © 1439 Ebtsam alkhuzai. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase
import SVProgressHUD


var metadataObj : AVMetadataMachineReadableCodeObject?


class HomeViewController: UIViewController , UITableViewDataSource , UITableViewDelegate{
    
    var transactions = [Transaction]()
    
    var ref:DatabaseReference?
    
    @IBOutlet weak var customerBalance: UILabel!
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var customerImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profile: UIButton!
    @IBOutlet weak var circle: UIImageView!
    var balance : Int = 0
    @IBOutlet weak var friendsPageIcon: UIButton!
    @IBOutlet weak var galleryPageIcon: UIButton!
    @IBOutlet weak var profilePageIcon: UIButton!
    
    

    
    @IBAction func cancel(_ sender: Any) {
 dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! TransactionCell
        
        
        var transactionCell :Transaction
        
      transactionCell = self.transactions[indexPath.row]
      cell.transactionAmount.text = NSString(format:"%d", transactionCell.amount!) as String
        cell.transactionName.text = transactionCell.receiver
       cell.transactionDate.text = transactionCell.dateTime
        
       // cell.textLabel?.text = "ji"
      //  cell.textLabel?.textColor = UIColor.white
       
        
        
        return cell
    }
    
 func profileInfo(){
    
    self.ref = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    print(userID!)
    ref?.child("users").child("customer").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
        var value = snapshot.value as! [String : Any]
        self.userName.text = value["name"] as! String
        var balance = value["userBalance"]
        self.customerBalance.text = NSString(format:"%d",balance! as! Int) as String
        
        //get image url
        let url = value["QRCode"] as? String
        print("Got image url. that we dont need lol.")
        
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
                self.customerImage.image = image
                print("Displayed image.")
                
            }
        }
    })

    }
    
    func loadTran(){
        
        
      let userID = Auth.auth().currentUser?.uid
ref?.child("users").child("customer").child(userID!).child("transactionsHistory").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.childrenCount > 0 {
                self.transactions.removeAll()
                
                for tran in snapshot.children.allObjects as![DataSnapshot]{
                    let trans = tran.value as? [String: Any]
                    let receiverr = trans?["receiver"]
                    let amount = trans?["amount"]
                    let date = trans?["date"]
                    let time = trans?["time"]
                    let transa = Transaction(receiver: receiverr as! String? , amount:amount as! Int? , date:date as! String?, time:time as! String?)
                    self.transactions.append(transa)
                    
                    print("*********************************************** secound")
                    print(receiverr!)
                    
                }
                self.transactionTableView.reloadData()
            }
        })
    }
    
    @IBAction func openProfile(_ sender: Any) {
        
        profileView.isHidden = false
        self.circle.isHidden = true
        self.profilePageIcon.isHidden = true
        self.friendsPageIcon.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }
    var captureSession = AVCaptureSession()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileInfo()
        loadTran()
        self.transactionTableView.separatorStyle = UITableViewCellSeparatorStyle.none

        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:[AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.back)
        
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        
       // profile
        view.bringSubview(toFront: profile)
         view.bringSubview(toFront: profileView)
         view.bringSubview(toFront: transactionTableView)
        //transactionTableView
       view.bringSubview(toFront: circle)
        view.bringSubview(toFront: friendsPageIcon)
        view.bringSubview(toFront: galleryPageIcon)
        view.bringSubview(toFront: profilePageIcon)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Helper methods
    
    func launchApp(decodedURL: String) {
        
        if presentedViewController != nil {
            return
        }
        //CHANGE
    
       ref = Database.database().reference()
          var merchant =  ((metadataObj?.stringValue!)!)
            let userID = Auth.auth().currentUser?.uid
        
        
        self.ref?.child("users").child("merchants").observe(.childAdded) {(snapshot) in
            if snapshot.key == merchant {
                 self.performSegue(withIdentifier: "QrSelected", sender: self)
            }
  
    
        
            if userID == merchant {
                SVProgressHUD.showError(withStatus: "you can't make friends ship with your self!")
                print("noooooo22222")}
        
        
      self.ref?.child("users").child("customer").child(userID!).child("friends").observeSingleEvent(of: .value, with: { (snapshot2) in
            if snapshot2.childrenCount > 0 && userID != merchant{
               print("6565656\(snapshot2)")
                for friend in snapshot2.children.allObjects as![DataSnapshot]{
                    let fri = friend.value as? [String: String]
                    let frie = fri?["FriendID"]
                    if frie == merchant{
                        SVProgressHUD.showError(withStatus: "already exist ")
                        print("noooooo")
                    }
                    
                    
                }}else if userID != merchant &&  snapshot.key != merchant{
                 self.performSegue(withIdentifier: "friendQrSelected", sender: self)
            }
        
        
      })
        }

    }
    
    @IBAction func logOutButton(_ sender: UIButton) {
        
        print(Auth.auth().currentUser)
        do {
            try Auth.auth().signOut()
        }
        catch let logOutError {
            print(logOutError)
        }
        
        print(Auth.auth().currentUser)
        
        let storyBoard = UIStoryboard(name: "LogInSignUp" , bundle: nil)
        let signInVC = storyBoard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(signInVC, animated: true, completion: nil)
        SVProgressHUD.showSuccess(withStatus: "Signed out")
        
    }
}


extension HomeViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
           // messageLabel.text = "No QR code is detected"
            return
        }
       
 
         // Get the metadata object.
        
        metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
         
        if supportedCodeTypes.contains((metadataObj?.type)!) {
         // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj!)
         qrCodeFrameView?.frame = barCodeObject!.bounds
         
            if metadataObj?.stringValue != nil {
                launchApp(decodedURL: (metadataObj?.stringValue!)!)
                circle.image = UIImage(named: "green")
          //  messageLabel.text = metadataObj?.stringValue
         }
         }

    }
 

}

